package pl.codeleak.demos.sbt.entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name="DO_UONG")
public class DoUong {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column
    private String ten;

    @Column
    private Float gia;

}
