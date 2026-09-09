/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export interface HistoryItem {
  id: string;
  expression: string;
  result: string;
  timestamp: number;
  mode: string;
}

class HistoryModel {
  private static instance: HistoryModel;
  private dataPreferences?: preferences.Preferences;
  private readonly STORE_NAME: string = 'history_store';
  private readonly KEY_HISTORY: string = 'history_list';
  private maxHistorySize: number = 100;
  private isInitialized: boolean = false;

  private constructor() {}

  static getInstance(): HistoryModel {
    if (!HistoryModel.instance) {
      HistoryModel.instance = new HistoryModel();
    }
    return HistoryModel.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, this.STORE_NAME);
      this.isInitialized = true;
      console.info('[HistoryModel] Initialized successfully');
    } catch (error) {
      console.error('[HistoryModel] init failed: ' + JSON.stringify(error));
      this.isInitialized = false;
    }
  }

  async getHistory(): Promise<HistoryItem[]> {
    try {
      if (!this.isInitialized || !this.dataPreferences) {
        console.warn('[HistoryModel] Not initialized, returning empty');
        return [];
      }
      const jsonStr = await this.dataPreferences.get(this.KEY_HISTORY, '[]') as string;
      return JSON.parse(jsonStr) as HistoryItem[];
    } catch (error) {
      console.error('[HistoryModel] getHistory failed: ' + JSON.stringify(error));
      return [];
    }
  }

  async addHistory(expression: string, result: string, mode: string): Promise<void> {
    try {
      console.info('[HistoryModel] addHistory called: ' + expression + ' = ' + result);

      if (!this.isInitialized || !this.dataPreferences) {
        console.warn('[HistoryModel] Not initialized, skip saving');
        return;
      }

      if (!expression || !result) {
        console.warn('[HistoryModel] Empty expression or result, skip');
        return;
      }

      if (result === 'NaN' || result === '错误' || result === 'Error' || result === 'Infinity') {
        console.warn('[HistoryModel] Invalid result, skip');
        return;
      }

      const history = await this.getHistory();

      // 检查是否已存在相同的记录（避免重复）
      const exists = history.some(item =>
      item.expression === expression && item.result === result
      );
      if (exists) {
        console.info('[HistoryModel] Record already exists, skip');
        return;
      }

      const newItem: HistoryItem = {
        id: Date.now() + '_' + Math.random().toString(36).substring(2, 6),
        expression: expression,
        result: result,
        timestamp: Date.now(),
        mode: mode || 'basic'
      };

      history.unshift(newItem);

      if (history.length > this.maxHistorySize) {
        history.splice(this.maxHistorySize);
      }

      await this.saveHistory(history);
      console.info('[HistoryModel] History saved, total: ' + history.length);
    } catch (error) {
      console.error('[HistoryModel] addHistory failed: ' + JSON.stringify(error));
    }
  }

  async deleteHistory(id: string): Promise<void> {
    try {
      if (!this.isInitialized || !this.dataPreferences) {
        console.warn('[HistoryModel] Not initialized, skip delete');
        return;
      }
      const history = await this.getHistory();
      const index = history.findIndex(item => item.id === id);
      if (index !== -1) {
        history.splice(index, 1);
        await this.saveHistory(history);
        console.info('[HistoryModel] Deleted history item: ' + id);
      }
    } catch (error) {
      console.error('[HistoryModel] deleteHistory failed: ' + JSON.stringify(error));
    }
  }

  async clearHistory(): Promise<void> {
    try {
      if (!this.isInitialized || !this.dataPreferences) {
        console.warn('[HistoryModel] Not initialized, skip clear');
        return;
      }
      await this.saveHistory([]);
      console.info('[HistoryModel] History cleared');
    } catch (error) {
      console.error('[HistoryModel] clearHistory failed: ' + JSON.stringify(error));
    }
  }

  private async saveHistory(history: HistoryItem[]): Promise<void> {
    try {
      if (!this.isInitialized || !this.dataPreferences) {
        return;
      }
      await this.dataPreferences.put(this.KEY_HISTORY, JSON.stringify(history));
      await this.dataPreferences.flush();
    } catch (error) {
      console.error('[HistoryModel] saveHistory failed: ' + JSON.stringify(error));
    }
  }

  isReady(): boolean {
    return this.isInitialized && this.dataPreferences !== undefined;
  }
}

export default HistoryModel;