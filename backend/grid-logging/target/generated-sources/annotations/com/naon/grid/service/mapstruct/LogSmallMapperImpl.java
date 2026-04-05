package com.naon.grid.service.mapstruct;

import com.naon.grid.domain.SysLog;
import com.naon.grid.service.dto.SysLogSmallDto;
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
public class LogSmallMapperImpl implements LogSmallMapper {

    @Override
    public SysLog toEntity(SysLogSmallDto dto) {
        if ( dto == null ) {
            return null;
        }

        SysLog sysLog = new SysLog();

        sysLog.setDescription( dto.getDescription() );
        sysLog.setRequestIp( dto.getRequestIp() );
        sysLog.setAddress( dto.getAddress() );
        sysLog.setBrowser( dto.getBrowser() );
        sysLog.setTime( dto.getTime() );
        sysLog.setCreateTime( dto.getCreateTime() );

        return sysLog;
    }

    @Override
    public SysLogSmallDto toDto(SysLog entity) {
        if ( entity == null ) {
            return null;
        }

        SysLogSmallDto sysLogSmallDto = new SysLogSmallDto();

        sysLogSmallDto.setDescription( entity.getDescription() );
        sysLogSmallDto.setRequestIp( entity.getRequestIp() );
        sysLogSmallDto.setTime( entity.getTime() );
        sysLogSmallDto.setAddress( entity.getAddress() );
        sysLogSmallDto.setBrowser( entity.getBrowser() );
        sysLogSmallDto.setCreateTime( entity.getCreateTime() );

        return sysLogSmallDto;
    }

    @Override
    public List<SysLog> toEntity(List<SysLogSmallDto> dtoList) {
        if ( dtoList == null ) {
            return null;
        }

        List<SysLog> list = new ArrayList<SysLog>( dtoList.size() );
        for ( SysLogSmallDto sysLogSmallDto : dtoList ) {
            list.add( toEntity( sysLogSmallDto ) );
        }

        return list;
    }

    @Override
    public List<SysLogSmallDto> toDto(List<SysLog> entityList) {
        if ( entityList == null ) {
            return null;
        }

        List<SysLogSmallDto> list = new ArrayList<SysLogSmallDto>( entityList.size() );
        for ( SysLog sysLog : entityList ) {
            list.add( toDto( sysLog ) );
        }

        return list;
    }
}
