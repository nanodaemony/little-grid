package com.naon.grid.modules.maint.service.mapstruct;

import com.naon.grid.modules.maint.domain.Database;
import com.naon.grid.modules.maint.service.dto.DatabaseDto;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-05T13:33:31+0800",
    comments = "version: 1.4.2.Final, compiler: javac, environment: Java 22.0.2 (Oracle Corporation)"
)
@Component
public class DatabaseMapperImpl implements DatabaseMapper {

    @Override
    public Database toEntity(DatabaseDto dto) {
        if ( dto == null ) {
            return null;
        }

        Database database = new Database();

        database.setCreateBy( dto.getCreateBy() );
        database.setUpdateBy( dto.getUpdateBy() );
        database.setCreateTime( dto.getCreateTime() );
        database.setUpdateTime( dto.getUpdateTime() );
        database.setId( dto.getId() );
        database.setName( dto.getName() );
        database.setJdbcUrl( dto.getJdbcUrl() );
        database.setPwd( dto.getPwd() );
        database.setUserName( dto.getUserName() );

        return database;
    }

    @Override
    public DatabaseDto toDto(Database entity) {
        if ( entity == null ) {
            return null;
        }

        DatabaseDto databaseDto = new DatabaseDto();

        databaseDto.setCreateBy( entity.getCreateBy() );
        databaseDto.setUpdateBy( entity.getUpdateBy() );
        databaseDto.setCreateTime( entity.getCreateTime() );
        databaseDto.setUpdateTime( entity.getUpdateTime() );
        databaseDto.setId( entity.getId() );
        databaseDto.setName( entity.getName() );
        databaseDto.setJdbcUrl( entity.getJdbcUrl() );
        databaseDto.setPwd( entity.getPwd() );
        databaseDto.setUserName( entity.getUserName() );

        return databaseDto;
    }

    @Override
    public List<Database> toEntity(List<DatabaseDto> dtoList) {
        if ( dtoList == null ) {
            return null;
        }

        List<Database> list = new ArrayList<Database>( dtoList.size() );
        for ( DatabaseDto databaseDto : dtoList ) {
            list.add( toEntity( databaseDto ) );
        }

        return list;
    }

    @Override
    public List<DatabaseDto> toDto(List<Database> entityList) {
        if ( entityList == null ) {
            return null;
        }

        List<DatabaseDto> list = new ArrayList<DatabaseDto>( entityList.size() );
        for ( Database database : entityList ) {
            list.add( toDto( database ) );
        }

        return list;
    }
}
