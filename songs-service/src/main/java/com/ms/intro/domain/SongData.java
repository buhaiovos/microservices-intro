package com.ms.intro.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Entity
@Table(name = "songs")
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class SongData {

    @Id
    @GeneratedValue
    int id;

    @Column
    String name;

    @Column
    String artist;

    @Column
    String album;

    @Column
    String genre;

    @Column
    String length;

    @Column(unique = true, nullable = false)
    Integer resourceId;

    @Column
    String year;
}
