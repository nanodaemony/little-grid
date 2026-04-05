package com.naon.grid.modules.maint.service.mapstruct;

import com.naon.grid.modules.maint.domain.ServerDeploy;
import com.naon.grid.modules.maint.service.dto.ServerDeployDto;
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
public class ServerDeployMapperImpl implements ServerDeployMapper {

    @Override
    public ServerDeploy toEntity(ServerDeployDto dto) {
        if ( dto == null ) {
            return null;
        }

        ServerDeploy serverDeploy = new ServerDeploy();

        serverDeploy.setCreateBy( dto.getCreateBy() );
        serverDeploy.setUpdateBy( dto.getUpdateBy() );
        serverDeploy.setCreateTime( dto.getCreateTime() );
        serverDeploy.setUpdateTime( dto.getUpdateTime() );
        serverDeploy.setId( dto.getId() );
        serverDeploy.setName( dto.getName() );
        serverDeploy.setIp( dto.getIp() );
        serverDeploy.setPort( dto.getPort() );
        serverDeploy.setAccount( dto.getAccount() );
        serverDeploy.setPassword( dto.getPassword() );

        return serverDeploy;
    }

    @Override
    public ServerDeployDto toDto(ServerDeploy entity) {
        if ( entity == null ) {
            return null;
        }

        ServerDeployDto serverDeployDto = new ServerDeployDto();

        serverDeployDto.setCreateBy( entity.getCreateBy() );
        serverDeployDto.setUpdateBy( entity.getUpdateBy() );
        serverDeployDto.setCreateTime( entity.getCreateTime() );
        serverDeployDto.setUpdateTime( entity.getUpdateTime() );
        serverDeployDto.setId( entity.getId() );
        serverDeployDto.setName( entity.getName() );
        serverDeployDto.setIp( entity.getIp() );
        serverDeployDto.setPort( entity.getPort() );
        serverDeployDto.setAccount( entity.getAccount() );
        serverDeployDto.setPassword( entity.getPassword() );

        return serverDeployDto;
    }

    @Override
    public List<ServerDeploy> toEntity(List<ServerDeployDto> dtoList) {
        if ( dtoList == null ) {
            return null;
        }

        List<ServerDeploy> list = new ArrayList<ServerDeploy>( dtoList.size() );
        for ( ServerDeployDto serverDeployDto : dtoList ) {
            list.add( toEntity( serverDeployDto ) );
        }

        return list;
    }

    @Override
    public List<ServerDeployDto> toDto(List<ServerDeploy> entityList) {
        if ( entityList == null ) {
            return null;
        }

        List<ServerDeployDto> list = new ArrayList<ServerDeployDto>( entityList.size() );
        for ( ServerDeploy serverDeploy : entityList ) {
            list.add( toDto( serverDeploy ) );
        }

        return list;
    }
}
