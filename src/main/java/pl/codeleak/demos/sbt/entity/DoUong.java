package pl.codeleak.demos.sbt.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name="DO_UONG")
public class DoUong {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "MA_DO_UONG")
    private String maDoUong;

    @Column
    private String ten;

    @Column
    private Float gia;

}
