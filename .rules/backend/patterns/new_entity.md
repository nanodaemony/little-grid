# Entity 模板

```java
package com.naon.grid.modules.xxx.domain;

import io.swagger.annotations.ApiModelProperty;
import lombok.Getter;
import lombok.Setter;
import com.naon.grid.base.BaseEntity;
import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.Serializable;
import java.util.Objects;

@Entity
@Getter
@Setter
@Table(name = "xxx")
public class Xxx extends BaseEntity implements Serializable {

    @Id
    @Column(name = "id")
    @NotNull(groups = Update.class)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @ApiModelProperty(value = "ID", hidden = true)
    private Long id;

    @NotBlank
    @Column(name = "name")
    @ApiModelProperty(value = "名称")
    private String name;

    @Column(name = "description")
    @ApiModelProperty(value = "描述")
    private String description;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Xxx xxx = (Xxx) o;
        return Objects.equals(id, xxx.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
```
