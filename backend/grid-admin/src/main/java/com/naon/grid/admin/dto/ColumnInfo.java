package com.naon.grid.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ColumnInfo {
    private String name;
    private String type;
    private String nullable;
    private String keyType;
    private Object defaultValue;
    private String comment;
    private Boolean autoIncrement;
}
