package com.naon.grid.service.mapstruct;

import com.naon.grid.domain.SysLog;
import com.naon.grid.service.dto.SysLogErrorDto;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-04-05T13:33:27+0800",
    comments = "version: 1.4.2.Final, compiler: javac, environment: Java 22.0.2 (Oracle Corporation)"
)
@Component
public class LogErrorMapperImpl implements LogErrorMapper {

    @Override
    public SysLog toEntity(SysLogErrorDto dto) {
        if ( dto == null ) {
            return null;
        }

        SysLog sysLog = new SysLog();

        sysLog.setId( dto.getId() );
        sysLog.setUsername( dto.getUsername() );
        sysLog.setDescription( dto.getDescription() );
        sysLog.setMethod( dto.getMethod() );
        sysLog.setParams( dto.getParams() );
        sysLog.setRequestIp( dto.getRequestIp() );
        sysLog.setAddress( dto.getAddress() );
        sysLog.setBrowser( dto.getBrowser() );
        sysLog.setCreateTime( dto.getCreateTime() );

        return sysLog;
    }

    @Override
    public SysLogErrorDto toDto(SysLog entity) {
        if ( entity == null ) {
            return null;
        }

        SysLogErrorDto sysLogErrorDto = new SysLogErrorDto();

        sysLogErrorDto.setId( entity.getId() );
        sysLogErrorDto.setUsername( entity.getUsername() );
        sysLogErrorDto.setDescription( entity.getDescription() );
        sysLogErrorDto.setMethod( entity.getMethod() );
        sysLogErrorDto.setParams( entity.getParams() );
        sysLogErrorDto.setBrowser( entity.getBrowser() );
        sysLogErrorDto.setRequestIp( entity.getRequestIp() );
        sysLogErrorDto.setAddress( entity.getAddress() );
        sysLogErrorDto.setCreateTime( entity.getCreateTime() );

        return sysLogErrorDto;
    }

    @Override
    public List<SysLog> toEntity(List<SysLogErrorDto> dtoList) {
        if ( dtoList == null ) {
            return null;
        }

        List<SysLog> list = new ArrayList<SysLog>( dtoList.size() );
        for ( SysLogErrorDto sysLogErrorDto : dtoList ) {
            list.add( toEntity( sysLogErrorDto ) );
        }

        return list;
    }

    @Override
    public List<SysLogErrorDto> toDto(List<SysLog> entityList) {
        if ( entityList == null ) {
            return null;
        }

        List<SysLogErrorDto> list = new ArrayList<SysLogErrorDto>( entityList.size() );
        for ( SysLog sysLog : entityList ) {
            list.add( toDto( sysLog ) );
        }

        return list;
    }
}
