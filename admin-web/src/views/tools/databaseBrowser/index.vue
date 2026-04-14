<template>
  <div class="database-browser-container">
    <el-container style="height: calc(100vh - 84px);">
      <!-- 左侧表树 -->
      <el-aside width="280px" style="background-color: #f5f7fa; border-right: 1px solid #e4e7ed;">
        <TableTree
          ref="tableTree"
          @table-select="handleTableSelect"
        />
      </el-aside>

      <!-- 右侧内容区 -->
      <el-main style="padding: 0; display: flex; flex-direction: column;">
        <!-- 顶部标签页 -->
        <div class="view-tabs">
          <el-radio-group v-model="activeView" size="small" style="margin: 12px 16px;">
            <el-radio-button label="data">数据视图</el-radio-button>
            <el-radio-button label="structure">表结构</el-radio-button>
          </el-radio-group>
          <div style="flex: 1;"></div>
          <template v-if="currentTable">
            <el-tag size="small" :type="isSensitive ? 'danger' : 'success'" style="margin-right: 16px;">
              {{ isSensitive ? '敏感表' : '普通表' }}
            </el-tag>
            <span style="margin-right: 16px; color: #909399;">{{ currentTable }}</span>
          </template>
        </div>

        <!-- 内容区 -->
        <div class="content-area" v-loading="loading">
          <DataView
            v-if="activeView === 'data' && currentTable"
            ref="dataView"
            :table-name="currentTable"
            :columns="currentColumns"
            :is-sensitive="isSensitive"
          />
          <StructureView
            v-else-if="activeView === 'structure' && currentTable"
            ref="structureView"
            :table-name="currentTable"
          />
          <el-empty v-else description="请从左侧选择一个表" />
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import TableTree from './components/TableTree.vue'
import DataView from './components/DataView.vue'
import StructureView from './components/StructureView.vue'
import { isSensitiveTable } from '@/api/tools/databaseBrowser'

export default {
  name: 'DatabaseBrowser',
  components: { TableTree, DataView, StructureView },
  data() {
    return {
      activeView: 'data',
      currentTable: null,
      currentColumns: [],
      isSensitive: false,
      loading: false
    }
  },
  methods: {
    async handleTableSelect(tableInfo) {
      this.loading = true
      try {
        this.currentTable = tableInfo.tableName
        this.currentColumns = tableInfo.columns || []
        // 检查是否为敏感表
        const res = await isSensitiveTable(this.currentTable)
        this.isSensitive = res.data.sensitive
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.database-browser-container {
  height: 100%;
}
.view-tabs {
  display: flex;
  align-items: center;
  border-bottom: 1px solid #e4e7ed;
  background-color: #fff;
}
.content-area {
  flex: 1;
  overflow: auto;
  background-color: #fff;
}
</style>
