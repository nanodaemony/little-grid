<template>
  <el-dialog
    :title="isEdit ? '编辑数据' : '新增数据'"
    :visible.sync="dialogVisible"
    width="600px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form
      ref="form"
      :model="formData"
      :rules="rules"
      label-width="120px"
      v-loading="loading"
    >
      <el-form-item
        v-for="column in editableColumns"
        :key="column.columnName"
        :label="column.columnComment || column.columnName"
        :prop="column.columnName"
      >
        <!-- 数字类型 -->
        <el-input-number
          v-if="isNumberType(column.dataType)"
          v-model="formData[column.columnName]"
          :disabled="column.autoIncrement && !isEdit"
          style="width: 100%;"
        />
        <!-- 日期时间类型 -->
        <el-date-picker
          v-else-if="isDateTimeType(column.dataType)"
          v-model="formData[column.columnName]"
          type="datetime"
          placeholder="选择日期时间"
          style="width: 100%;"
          value-format="yyyy-MM-dd HH:mm:ss"
        />
        <!-- 日期类型 -->
        <el-date-picker
          v-else-if="isDateType(column.dataType)"
          v-model="formData[column.columnName]"
          type="date"
          placeholder="选择日期"
          style="width: 100%;"
          value-format="yyyy-MM-dd"
        />
        <!-- 布尔类型 -->
        <el-switch
          v-else-if="isBooleanType(column.dataType)"
          v-model="formData[column.columnName]"
          :active-value="1"
          :inactive-value="0"
        />
        <!-- 长文本 -->
        <el-input
          v-else-if="isTextType(column.dataType)"
          v-model="formData[column.columnName]"
          type="textarea"
          :rows="4"
          :disabled="column.autoIncrement && !isEdit"
        />
        <!-- 默认文本输入 -->
        <el-input
          v-else
          v-model="formData[column.columnName]"
          :disabled="column.autoIncrement && !isEdit"
        />
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button type="primary" @click="handleSubmit" :loading="submitting">确 定</el-button>
    </div>
  </el-dialog>
</template>

<script>
import { insertData, updateData } from '@/api/tools/databaseBrowser'

export default {
  name: 'DataForm',
  props: {
    tableName: {
      type: String,
      required: true
    },
    columns: {
      type: Array,
      default: () => []
    },
    isSensitive: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      dialogVisible: false,
      isEdit: false,
      loading: false,
      submitting: false,
      formData: {},
      originalData: {},
      rules: {}
    }
  },
  computed: {
    editableColumns() {
      return this.columns.filter(col => !col.autoIncrement || this.isEdit)
    }
  },
  methods: {
    isNumberType(type) {
      const numTypes = ['INT', 'INTEGER', 'BIGINT', 'SMALLINT', 'TINYINT', 'DECIMAL', 'NUMERIC', 'FLOAT', 'DOUBLE']
      return numTypes.includes(type && type.toUpperCase())
    },
    isDateTimeType(type) {
      const dtTypes = ['DATETIME', 'TIMESTAMP']
      return dtTypes.includes(type && type.toUpperCase())
    },
    isDateType(type) {
      const dTypes = ['DATE', 'YEAR']
      return dTypes.includes(type && type.toUpperCase())
    },
    isBooleanType(type) {
      const bTypes = ['BOOLEAN', 'BOOL', 'BIT']
      return bTypes.includes(type && type.toUpperCase())
    },
    isTextType(type) {
      const tTypes = ['TEXT', 'LONGTEXT', 'MEDIUMTEXT', 'TINYTEXT', 'JSON']
      return tTypes.includes(type && type.toUpperCase())
    },
    openAdd() {
      this.isEdit = false
      this.formData = {}
      this.columns.forEach(col => {
        if (col.columnDefault !== null) {
          this.formData[col.columnName] = col.columnDefault
        } else {
          this.formData[col.columnName] = this.getDefaultValue(col)
        }
      })
      this.dialogVisible = true
    },
    openEdit(row) {
      this.isEdit = true
      this.originalData = { ...row }
      this.formData = { ...row }
      this.dialogVisible = true
    },
    getDefaultValue(column) {
      if (this.isNumberType(column.dataType)) {
        return 0
      }
      if (this.isBooleanType(column.dataType)) {
        return 0
      }
      return ''
    },
    async handleSubmit() {
      try {
        await this.$refs.form.validate()
      } catch {
        return
      }

      // 敏感表二次确认
      if (this.isSensitive) {
        try {
          await this.$confirm(
            `当前表「${this.tableName}」是敏感表，确定要${this.isEdit ? '修改' : '新增'}数据吗？`,
            '警告',
            {
              confirmButtonText: '确定',
              cancelButtonText: '取消',
              type: 'warning'
            }
          )
        } catch {
          return
        }
      }

      this.submitting = true
      try {
        if (this.isEdit) {
          // 获取主键作为 where 条件
          const whereClause = {}
          const primaryKeys = this.columns.filter(col => col.columnKey === 'PRI')
          if (primaryKeys.length > 0) {
            primaryKeys.forEach(col => {
              whereClause[col.columnName] = this.originalData[col.columnName]
            })
          } else {
            // 没有主键，使用所有原始数据作为条件
            Object.assign(whereClause, this.originalData)
          }
          await updateData(this.tableName, this.formData, whereClause)
          this.$message.success('修改成功')
        } else {
          // 过滤掉自增列的空值
          const data = { ...this.formData }
          this.columns.forEach(col => {
            if (col.autoIncrement && data[col.columnName] === '') {
              delete data[col.columnName]
            }
          })
          await insertData(this.tableName, data)
          this.$message.success('新增成功')
        }
        this.dialogVisible = false
        this.$emit('success')
      } catch (error) {
        this.$message.error(this.isEdit ? '修改失败' : '新增失败')
      } finally {
        this.submitting = false
      }
    },
    handleClose() {
      this.$refs.form && this.$refs.form.resetFields()
    }
  }
}
</script>

<style scoped>
</style>
