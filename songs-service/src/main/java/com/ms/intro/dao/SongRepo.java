package com.ms.intro.dao;

import java.util.Optional;
import java.util.stream.Stream;

import com.ms.intro.domain.SongData;
import org.springframework.data.repository.CrudRepository;

public interface SongRepo extends CrudRepository<SongData, Integer> {
    Optional<SongData> findByResourceId(int resourceId);
    void deleteByResourceId(int resourceId);
    Stream<SongData> findAllByGenre(String genre);
}