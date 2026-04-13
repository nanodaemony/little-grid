# Controller 模板

```java
package com.naon.grid.modules.xxx.rest;

import com.naon.grid.annotation.Log;
import com.naon.grid.modules.xxx.domain.Xxx;
import com.naon.grid.modules.xxx.service.XxxService;
import com.naon.grid.modules.xxx.service.dto.XxxDto;
import com.naon.grid.modules.xxx.service.dto.XxxQueryCriteria;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Api(tags = "Xxx管理")
@RequestMapping("/api/xxx")
public class XxxController {

    private final XxxService xxxService;

    @Log("查询Xxx")
    @ApiOperation("查询Xxx")
    @GetMapping
    @PreAuthorize("@el.check('xxx:list')")
    public ResponseEntity<Object> query(XxxQueryCriteria criteria, Pageable pageable) {
        return new ResponseEntity<>(xxxService.queryAll(criteria, pageable), HttpStatus.OK);
    }

    @Log("新增Xxx")
    @ApiOperation("新增Xxx")
    @PostMapping
    @PreAuthorize("@el.check('xxx:add')")
    public ResponseEntity<Object> create(@Validated @RequestBody Xxx resources) {
        xxxService.create(resources);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @Log("修改Xxx")
    @ApiOperation("修改Xxx")
    @PutMapping
    @PreAuthorize("@el.check('xxx:edit')")
    public ResponseEntity<Object> update(@Validated @RequestBody Xxx resources) {
        xxxService.update(resources);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @Log("删除Xxx")
    @ApiOperation("删除Xxx")
    @DeleteMapping
    @PreAuthorize("@el.check('xxx:del')")
    public ResponseEntity<Object> delete(@RequestBody Long[] ids) {
        xxxService.deleteAll(ids);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
```
