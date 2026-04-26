package com.naon.grid.admin.service;

import com.naon.grid.admin.dto.SqlExecuteResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DatabaseCrudService {

    private final DataSource dataSource;
    private final DatabaseMetadataService metadataService;

    private static final int MAX_ROWS = 1000;

    public Map<String, Object> getTableData(String tableName, int page, int size, String sort, String order) {
        metadataService.validateTableExists(tableName);
        try (Connection conn = dataSource.getConnection()) {
            long total = getRowCount(conn, tableName);
            String orderBy = "";
            if (sort != null && !sort.isEmpty()) {
                String dir = "desc".equalsIgnoreCase(order) ? "DESC" : "ASC";
                orderBy = " ORDER BY `" + sort + "` " + dir;
            }
            String sql = "SELECT * FROM `" + tableName + "`" + orderBy + " LIMIT ? OFFSET ?";
            List<Map<String, Object>> rows = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, size);
                ps.setInt(2, (page - 1) * size);
                try (ResultSet rs = ps.executeQuery()) {
                    ResultSetMetaData rsMeta = rs.getMetaData();
                    int colCount = rsMeta.getColumnCount();
                    while (rs.next()) {
                        Map<String, Object> row = new LinkedHashMap<>();
                        for (int i = 1; i <= colCount; i++) {
                            row.put(rsMeta.getColumnLabel(i), rs.getObject(i));
                        }
                        rows.add(row);
                    }
                }
            }
            Map<String, Object> result = new HashMap<>();
            result.put("rows", rows);
            result.put("total", total);
            result.put("page", page);
            result.put("size", size);
            return result;
        } catch (SQLException e) {
            log.error("Failed to query table data: {}", tableName, e);
            throw new RuntimeException("查询表数据失败: " + e.getMessage());
        }
    }

    public void insertRow(String tableName, Map<String, Object> data) {
        metadataService.validateTableExists(tableName);
        StringBuilder cols = new StringBuilder();
        StringBuilder vals = new StringBuilder();
        List<Object> params = new ArrayList<>();
        for (Map.Entry<String, Object> entry : data.entrySet()) {
            if (cols.length() > 0) {
                cols.append(", ");
                vals.append(", ");
            }
            cols.append("`").append(entry.getKey()).append("`");
            vals.append("?");
            params.add(entry.getValue());
        }
        String sql = "INSERT INTO `" + tableName + "` (" + cols + ") VALUES (" + vals + ")";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            log.error("Failed to insert row into table: {}", tableName, e);
            throw new RuntimeException("新增数据失败: " + e.getMessage());
        }
    }

    public void updateRow(String tableName, Map<String, Object> data) {
        metadataService.validateTableExists(tableName);
        try (Connection conn = dataSource.getConnection()) {
            Set<String> primaryKeys = metadataService.getPrimaryKeys(conn, tableName);
            if (primaryKeys.isEmpty()) {
                throw new IllegalArgumentException("该表无主键，不支持修改");
            }
            StringBuilder setClause = new StringBuilder();
            List<Object> setParams = new ArrayList<>();
            List<Object> whereParams = new ArrayList<>();
            StringBuilder whereClause = new StringBuilder();
            for (Map.Entry<String, Object> entry : data.entrySet()) {
                if (primaryKeys.contains(entry.getKey())) {
                    if (whereClause.length() > 0) whereClause.append(" AND ");
                    whereClause.append("`").append(entry.getKey()).append("` = ?");
                    whereParams.add(entry.getValue());
                } else {
                    if (setClause.length() > 0) setClause.append(", ");
                    setClause.append("`").append(entry.getKey()).append("` = ?");
                    setParams.add(entry.getValue());
                }
            }
            if (whereClause.length() == 0) {
                throw new IllegalArgumentException("请求中缺少主键字段");
            }
            String sql = "UPDATE `" + tableName + "` SET " + setClause + " WHERE " + whereClause;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int idx = 1;
                for (Object p : setParams) ps.setObject(idx++, p);
                for (Object p : whereParams) ps.setObject(idx++, p);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            log.error("Failed to update row in table: {}", tableName, e);
            throw new RuntimeException("更新数据失败: " + e.getMessage());
        }
    }

    public void deleteRow(String tableName, Map<String, Object> data) {
        metadataService.validateTableExists(tableName);
        try (Connection conn = dataSource.getConnection()) {
            Set<String> primaryKeys = metadataService.getPrimaryKeys(conn, tableName);
            if (primaryKeys.isEmpty()) {
                throw new IllegalArgumentException("该表无主键，不支持删除");
            }
            StringBuilder whereClause = new StringBuilder();
            List<Object> whereParams = new ArrayList<>();
            for (Map.Entry<String, Object> entry : data.entrySet()) {
                if (primaryKeys.contains(entry.getKey())) {
                    if (whereClause.length() > 0) whereClause.append(" AND ");
                    whereClause.append("`").append(entry.getKey()).append("` = ?");
                    whereParams.add(entry.getValue());
                }
            }
            if (whereClause.length() == 0) {
                throw new IllegalArgumentException("请求中缺少主键字段");
            }
            String sql = "DELETE FROM `" + tableName + "` WHERE " + whereClause;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < whereParams.size(); i++) {
                    ps.setObject(i + 1, whereParams.get(i));
                }
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            log.error("Failed to delete row from table: {}", tableName, e);
            throw new RuntimeException("删除数据失败: " + e.getMessage());
        }
    }

    public SqlExecuteResult executeSql(String sql) {
        String trimmed = sql.trim();
        if (!trimmed.toUpperCase().startsWith("SELECT")) {
            throw new IllegalArgumentException("仅允许 SELECT 查询");
        }
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(trimmed)) {
            ps.setMaxRows(MAX_ROWS + 1);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData rsMeta = rs.getMetaData();
                int colCount = rsMeta.getColumnCount();
                List<String> columns = new ArrayList<>();
                for (int i = 1; i <= colCount; i++) {
                    columns.add(rsMeta.getColumnLabel(i));
                }
                List<Map<String, Object>> rows = new ArrayList<>();
                int count = 0;
                boolean truncated = false;
                while (rs.next()) {
                    if (count >= MAX_ROWS) {
                        truncated = true;
                        break;
                    }
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= colCount; i++) {
                        row.put(rsMeta.getColumnLabel(i), rs.getObject(i));
                    }
                    rows.add(row);
                    count++;
                }
                return new SqlExecuteResult(columns, rows, truncated);
            }
        } catch (SQLException e) {
            log.error("Failed to execute SQL: {}", sql, e);
            throw new RuntimeException("SQL 执行失败: " + e.getMessage());
        }
    }

    private long getRowCount(Connection conn, String tableName) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM `" + tableName + "`");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getLong(1) : 0;
        }
    }
}