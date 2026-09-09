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

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import HistoryModel, { HistoryItem } from '../model/HistoryModel';
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct HistoryPage {
  @State historyList: HistoryItem[] = [];
  @State isDeleteMode: boolean = false;
  @State selectedIds: Set<string> = new Set();

  private historyModel: HistoryModel = HistoryModel.getInstance();
  private isReady: boolean = false;

  @StorageLink('topRectHeight') topRectHeight: number = 0;
  uiContext = this.getUIContext();

  aboutToAppear() {
    this.initHistoryModel();
  }

  async initHistoryModel() {
    try {
      // 尝试从AppStorage获取上下文
      let context = AppStorage.get<common.UIAbilityContext>('abilityContext');

      // 如果AppStorage中没有，尝试从UI上下文获取
      if (!context) {
        context = getContext(this) as common.UIAbilityContext;
      }

      if (context) {
        await this.historyModel.init(context);
        this.isReady = true;
        await this.loadHistory();
        console.info('[HistoryPage] Initialized successfully, count: ' + this.historyList.length);
      } else {
        console.warn('[HistoryPage] No context available');
      }
    } catch (error) {
      console.error('[HistoryPage] Init failed: ' + JSON.stringify(error));
    }
  }

  async loadHistory() {
    if (!this.isReady) {
      console.warn('[HistoryPage] Not ready, skip load');
      return;
    }
    try {
      this.historyList = await this.historyModel.getHistory();
      console.info('[HistoryPage] Loaded ' + this.historyList.length + ' records');
    } catch (error) {
      console.error('[HistoryPage] Load history failed: ' + JSON.stringify(error));
    }
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return month + '/' + day + ' ' + hours + ':' + minutes;
  }

  build() {
    Column() {
      this.TitleBar()
      if (this.historyList.length === 0) {
        this.EmptyView()
      } else {
        this.HistoryList()
      }
      this.BottomBar()
    }
    .width('100%')
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#F5F7FA')
    .padding({ top: this.uiContext.px2vp(this.topRectHeight) + 8 })
  }

  @Builder
  TitleBar() {
    Row() {
      Text('‹')
        .fontSize(28)
        .fontWeight(700)
        .fontColor('#0A59F7')
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          router.back();
        })

      Text('历史记录')
        .fontSize(20)
        .fontWeight(700)
        .fontColor('rgba(0, 0, 0, 0.9)')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.historyList.length > 0) {
        Text('清空')
          .fontSize(16)
          .fontColor('#FF3B30')
          .onClick(() => {
            this.showClearConfirm();
          })
      } else {
        Text('')
          .width(40)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)' })
  }

  @Builder
  EmptyView() {
    Column() {
      Text('📋')
        .fontSize(64)
        .margin({ top: 60 })

      Text('暂无计算记录')
        .fontSize(18)
        .fontColor('rgba(0, 0, 0, 0.4)')
        .margin({ top: 16 })

      Text('计算后会自动保存历史记录')
        .fontSize(14)
        .fontColor('rgba(0, 0, 0, 0.3)')
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HistoryList() {
    List({ space: 8 }) {
      ForEach(this.historyList, (item: HistoryItem, index: number) => {
        ListItem() {
          this.HistoryItemView(item, index)
        }
        .onClick(() => {
          if (this.isDeleteMode) {
            this.toggleSelect(item.id);
          }
        })
        .gesture(
          LongPressGesture({ duration: 500 })
            .onAction(() => {
              this.toggleDeleteMode();
            })
        )
      }, (item: HistoryItem) => item.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 12, bottom: 8 })
    .backgroundColor('transparent')
  }

  @Builder
  HistoryItemView(item: HistoryItem, index: number) {
    Row() {
      if (this.isDeleteMode) {
        Column() {
          if (this.selectedIds.has(item.id)) {
            Column()
              .width(20)
              .height(20)
              .borderRadius(10)
              .backgroundColor('#0A59F7')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center) {
              Text('✓')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(700)
            }
          } else {
            Column()
              .width(20)
              .height(20)
              .borderRadius(10)
              .border({ width: 2, color: '#CCCCCC' })
          }
        }
        .margin({ right: 12 })
        .width(24)
        .height(24)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      Column() {
        Row() {
          Text((index + 1) + '.')
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.3)')
            .margin({ right: 8 })

          Text(this.formatTime(item.timestamp))
            .fontSize(12)
            .fontColor('rgba(0, 0, 0, 0.3)')
            .layoutWeight(1)

          Text(item.mode === 'scientific' ? '科学' : '基础')
            .fontSize(10)
            .fontColor('#0A59F7')
            .backgroundColor('rgba(10, 89, 247, 0.08)')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
        }
        .width('100%')
        .margin({ bottom: 4 })

        Text(item.expression)
          .fontSize(18)
          .fontWeight(500)
          .fontColor('rgba(0, 0, 0, 0.8)')
          .textAlign(TextAlign.Start)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('= ' + item.result)
          .fontSize(22)
          .fontWeight(700)
          .fontColor('#0A59F7')
          .textAlign(TextAlign.End)
          .width('100%')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (!this.isDeleteMode) {
        Column() {
          Text('×')
            .fontSize(22)
            .fontColor('rgba(0, 0, 0, 0.2)')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.deleteSingleItem(item.id);
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  toggleDeleteMode() {
    this.isDeleteMode = !this.isDeleteMode;
    if (!this.isDeleteMode) {
      this.selectedIds.clear();
    }
  }

  toggleSelect(id: string) {
    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id);
    } else {
      this.selectedIds.add(id);
    }
    if (this.selectedIds.size === 0) {
      this.isDeleteMode = false;
    }
  }

  async deleteSingleItem(id: string) {
    await this.historyModel.deleteHistory(id);
    await this.loadHistory();
  }

  async batchDelete() {
    if (this.selectedIds.size === 0) return;

    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除选中的 ' + this.selectedIds.size + ' 条记录吗？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '删除',
        action: () => {
          for (const id of this.selectedIds) {
            this.historyModel.deleteHistory(id);
          }
          this.selectedIds.clear();
          this.isDeleteMode = false;
          this.loadHistory();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  showClearConfirm() {
    AlertDialog.show({
      title: '确认清空',
      message: '确定要清空所有历史记录吗？\n此操作不可恢复！',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '清空',
        action: () => {
          this.historyModel.clearHistory();
          this.loadHistory();
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {}
      }
    });
  }

  @Builder
  BottomBar() {
    if (this.isDeleteMode) {
      Row() {
        Text('已选择 ' + this.selectedIds.size + ' 条')
          .fontSize(14)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .layoutWeight(1)

        Button('删除所选')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.selectedIds.size > 0 ? '#FF3B30' : '#CCCCCC')
          .height(36)
          .borderRadius(18)
          .padding({ left: 20, right: 20 })
          .enabled(this.selectedIds.size > 0)
          .onClick(() => {
            this.batchDelete();
          })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetY: -2 })
    }
  }
}