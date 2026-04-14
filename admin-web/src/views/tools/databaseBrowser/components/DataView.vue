<template>
  <div class="data-view-container">
    <!-- 操作栏 -->
    <div class="action-bar">
      <el-button type="primary" icon="el-icon-plus" size="small" @click="handleAdd">新增</el-button>
      <el-button type="danger" icon="el-icon-delete" size="small" :disabled="selectedRows.length === 0" @click="handleBatchDelete">删除</el-button>
      <span style="color: #909399; margin-left: 16px;">共 {{ total }} 条</span>
    </div>

    <!-- 数据表格 -->
    <el-table
      :data="rows"
      border
      stripe
      style="width: 100%;"
      v-loading="loading"
      @selection-change="handleSelectionChange"
      max-height="calc(100vh - 220px)"
    >
      <el-table-column type="selection" width="55" />
      <el-table-column
        v-for="column in displayColumns"
        :key="column.columnName"
        :prop="column.columnName"
        :label="column.columnComment || column.columnName"
        :min-width="getColumnWidth(column)"
        show-overflow-tooltip
      >
        <template slot-scope="scope">
          <span v-if="scope.row[column.columnName] === null" style="color: #c0c4cc;">NULL</span>
          <span v-else>{{ formatValue(scope.row[column.columnName]) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template slot-scope="scope">
          <el-button type="text" size="small" @click="handleEdit(scope.row)">编辑</el-button>
          <el-button type="text" size="small" class="el-button--danger" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-bar">
      <el-pagination
        background
        layout="prev, pager, next, jumper"
        :total="total"
        :page-size="pageSize"
        :current-page="currentPage"
        @current-change="handlePageChange"
      />
    </div>

    <!-- 数据编辑对话框（通过 ref 调用） -->
    <DataForm
      ref="dataForm"
      :table-name="tableName"
      :columns="displayColumns"
      :is-sensitive="isSensitive"
      @success="refresh"
    />
  </div>
</template>

<script>
import { getTableData, deleteData } from '@/api/tools/databaseBrowser'
import DataForm from './DataForm.vue'

export default {
  name: 'DataView',
  components: { DataForm },
  props: {
    tableName: {
      type: String,
      required: true
    },
    columns: {
      type: Array,
      default: () => []
    },
    isSensitive: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      loading: false,
      internalColumns: [],
      rows: [],
      total: 0,
      currentPage: 1,
      pageSize: 20,
      selectedRows: []
    }
  },
  computed: {
    displayColumns() {
      if (this.columns && this.columns.length > 0) {
        return this.columns
      }
      return this.internalColumns
    }
  },
  watch: {
    tableName: {
      immediate: true,
      handler() {
        this.currentPage = 1
        this.refresh()
      }
    }
  },
  methods: {
    async refresh() {
      if (!this.tableName) return
      this.loading = true
      try {
        const res = await getTableData(this.tableName, this.currentPage, this.pageSize)
        this.internalColumns = res.data.columns || []
        this.rows = res.data.rows || []
        this.total = res.data.total || 0
      } catch (error) {
        this.$message.error('加载数据失败')
      } finally {
        this.loading = false
      }
    },
    getColumnWidth(column) {
      if (column.columnKey === 'PRI') return 120
      if (column.dataType === 'DATETIME' || column.dataType === 'TIMESTAMP') return 180
      if (column.dataType === 'DATE') return 120
      if (column.columnName.includes('name') || column.columnName.includes('title')) return 150
      return 100
    },
    formatValue(value) {
      if (typeof value === 'boolean') {
        return value ? 'true' : 'false'
      }
      return value
    },
    handleSelectionChange(rows) {
      this.selectedRows = rows
    },
    handlePageChange(page) {
      this.currentPage = page
      this.refresh()
    },
    handleAdd() {
      this.$refs.dataForm.openAdd()
    },
    handleEdit(row) {
      this.$refs.dataForm.openEdit(row)
    },
    async handleDelete(row) {
      try {
        await this.$confirm('确定要删除这条数据吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })

        // 敏感表二次确认
        if (this.isSensitive) {
          await this.$confirm(
            `当前表「${this.tableName}」是敏感表，确定要删除数据吗？`,
            '警告',
            {
              confirmButtonText: '确定',
              cancelButtonText: '取消',
              type: 'warning'
            }
          )
        }

        // 构建删除条件
        const whereClause = {}
        const primaryKeys = this.displayColumns.filter(col => col.columnKey === 'PRI')
        if (primaryKeys.length > 0) {
          primaryKeys.forEach(col => {
            whereClause[col.columnName] = row[col.columnName]
          })
        } else {
          // 没有主键，使用所有列作为条件
          Object.assign(whereClause, row)
        }

        await deleteData(this.tableName, whereClause)
        this.$message.success('删除成功')
        this.refresh()
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('删除失败')
        }
      }
    },
    async handleBatchDelete() {
      try {
        await this.$confirm(`确定要删除选中的 ${this.selectedRows.length} 条数据吗？`, '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })

        // 敏感表二次确认
        if (this.isSensitive) {
          await this.$confirm(
            `当前表「${this.tableName}」是敏感表，确定要批量删除数据吗？`,
            '警告',
            {
              confirmButtonText: '确定',
              cancelButtonText: '取消',
              type: 'warning'
            }
          )
        }

        // 逐条删除
        for (const row of this.selectedRows) {
          const whereClause = {}
          const primaryKeys = this.displayColumns.filter(col => col.columnKey === 'PRI')
          if (primaryKeys.length > 0) {
            primaryKeys.forEach(col => {
              whereClause[col.columnName] = row[col.columnName]
            })
          } else {
            Object.assign(whereClause, row)
          }
          await deleteData(this.tableName, whereClause)
        }

        this.$message.success('删除成功')
        this.refresh()
      } catch (error) {
        if (error !== 'cancel') {
          this.$message.error('删除失败')
        }
      }
    }
  }
}
</script>

<style scoped>
.data-view-container {
  padding: 16px;
  display: flex;
  flex-direction: column;
  height: 100%;
}
.action-bar {
  margin-bottom: 12px;
  display: flex;
  align-items: center;
}
.pagination-bar {
  margin-top: 12px;
  display: flex;
  justify-content: flex-end;
}
.el-button--danger {
  color: #F56C6C;
}
</style>
