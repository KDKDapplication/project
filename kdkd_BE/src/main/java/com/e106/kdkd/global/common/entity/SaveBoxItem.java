package com.e106.kdkd.global.common.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "save_box_item")
public class SaveBoxItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "save_box_item_seq")
    private Long saveBoxItemSeq;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "box_uuid", nullable = false,
            foreignKey = @ForeignKey(name = "fk_saveboxitem_box"))
    private SaveBox box;

    @Column(name = "box_pay_name", length = 20, nullable = false)
    private String boxPayName;

    @Column(name = "box_transfer_date", nullable = false)
    private LocalDateTime boxTransferDate; // DB default CURRENT_TIMESTAMP

    @Column(name = "box_amount", nullable = false)
    private Long boxAmount;
}
