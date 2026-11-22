package com.ms.intro.mapper;

import com.ms.intro.domain.SongData;
import com.ms.intro.dto.SongDto;
import org.mapstruct.Mapper;
import org.mapstruct.factory.Mappers;

@Mapper
public interface SongDtoToDomainMapper {
    SongDtoToDomainMapper INSTANCE = Mappers.getMapper( SongDtoToDomainMapper.class );
    SongData toData(SongDto dto);
    SongDto toDto(SongData dto);
}
