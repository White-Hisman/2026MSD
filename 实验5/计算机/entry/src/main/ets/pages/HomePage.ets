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

import Logger from '../common/util/Logger';
import CheckEmptyUtil from '../common/util/CheckEmptyUtil';
import { CommonConstants } from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import HistoryModel from '../model/HistoryModel';

const HISTORY_STORAGE_KEY: string = 'calculator_history';
const SELECTED_HISTORY_KEY: string = 'calculator_selected_history';
const ANSWER_STORAGE_KEY: string = 'calculator_answer';

class HistoryRecord {
  expression: string;
  result: string;
  tokens: Array<string>;
  time: string;

  constructor(
    expression: string,
    result: string,
    tokens: Array<string>,
    time?: string
  ) {
    this.expression = expression;
    this.result = result;
    this.tokens = tokens;
    this.time = time === undefined ? this.getTime() : time;
  }

  private getTime(): string {
    const date: Date = new Date();
    const hour: number = date.getHours();
    const minute: number = date.getMinutes();
    const hourText: string = hour < 10 ? `0${hour}` : `${hour}`;
    const minuteText: string = minute < 10 ? `0${minute}` : `${minute}`;
    return `${hourText}:${minuteText}`;
  }
}

/**
 * 科学表达式计算器。
 * 支持加减乘除、括号、百分比、幂、阶乘、三角函数、对数和常量。
 */
class ScientificExpressionCalculator {
  private expression: string = '';
  private index: number = 0;
  private degreeMode: boolean = true;

  calculate(expression: string, degreeMode: boolean): string {
    if (expression.length === 0) {
      return 'NaN';
    }

    try {
      this.expression = expression
        .replace(/×/g, '*')
        .replace(/÷/g, '/')
        .replace(/√/g, 'sqrt')
        .replace(/\s/g, '');
      this.index = 0;
      this.degreeMode = degreeMode;

      const result: number = this.parseExpression();

      if (this.index < this.expression.length || !Number.isFinite(result)) {
        return 'NaN';
      }

      return this.formatNumber(result);
    } catch (error) {
      return 'NaN';
    }
  }

  private parseExpression(): number {
    let value: number = this.parseTerm();

    while (this.index < this.expression.length) {
      const operator: string = this.expression.charAt(this.index);

      if (operator === '+') {
        this.index++;
        value += this.parseTerm();
      } else if (operator === '-') {
        this.index++;
        value -= this.parseTerm();
      } else {
        break;
      }
    }

    return value;
  }

  private parseTerm(): number {
    let value: number = this.parsePower();

    while (this.index < this.expression.length) {
      const operator: string = this.expression.charAt(this.index);

      if (operator === '*') {
        this.index++;
        value *= this.parsePower();
      } else if (operator === '/') {
        this.index++;
        const divisor: number = this.parsePower();
        if (divisor === 0) {
          throw new Error('Division by zero');
        }
        value /= divisor;
      } else if (this.isImplicitMultiplyStart(operator)) {
        value *= this.parsePower();
      } else {
        break;
      }
    }

    return value;
  }

  private parsePower(): number {
    let value: number = this.parseUnary();

    if (this.expression.charAt(this.index) === '^') {
      this.index++;
      value = Math.pow(value, this.parsePower());
    }

    return value;
  }

  private parseUnary(): number {
    const current: string = this.expression.charAt(this.index);

    if (current === '+') {
      this.index++;
      return this.parseUnary();
    }

    if (current === '-') {
      this.index++;
      return -this.parseUnary();
    }

    return this.parsePostfix();
  }

  private parsePostfix(): number {
    let value: number = this.parsePrimary();

    while (this.index < this.expression.length) {
      const current: string = this.expression.charAt(this.index);

      if (current === '%') {
        this.index++;
        value /= 100;
      } else if (current === '!') {
        this.index++;
        value = this.factorial(value);
      } else {
        break;
      }
    }

    return value;
  }

  private parsePrimary(): number {
    const current: string = this.expression.charAt(this.index);

    if (current === '(') {
      this.index++;
      const value: number = this.parseExpression();

      if (this.expression.charAt(this.index) !== ')') {
        throw new Error('Missing closing parenthesis');
      }

      this.index++;
      return value;
    }

    if (current === 'π') {
      this.index++;
      return Math.PI;
    }

    if ((current >= '0' && current <= '9') || current === '.') {
      return this.parseNumber();
    }

    if (this.isLetter(current)) {
      return this.parseFunctionOrConstant();
    }

    throw new Error('Invalid expression');
  }

  private parseNumber(): number {
    const start: number = this.index;
    let hasExponent: boolean = false;

    while (this.index < this.expression.length) {
      const current: string = this.expression.charAt(this.index);

      if ((current >= '0' && current <= '9') || current === '.') {
        this.index++;
        continue;
      }

      if ((current === 'e' || current === 'E') && !hasExponent) {
        hasExponent = true;
        this.index++;

        const sign: string = this.expression.charAt(this.index);
        if (sign === '+' || sign === '-') {
          this.index++;
        }
        continue;
      }

      break;
    }

    const value: number = Number(
      this.expression.substring(start, this.index)
    );

    if (Number.isNaN(value)) {
      throw new Error('Invalid number');
    }

    return value;
  }

  private parseFunctionOrConstant(): number {
    const start: number = this.index;

    while (
      this.index < this.expression.length &&
        this.isLetter(this.expression.charAt(this.index))
    ) {
      this.index++;
    }

    const name: string = this.expression.substring(start, this.index);

    if (name === 'e') {
      return Math.E;
    }

    if (this.expression.charAt(this.index) !== '(') {
      throw new Error('Invalid function');
    }

    this.index++;
    const parameter: number = this.parseExpression();

    if (this.expression.charAt(this.index) !== ')') {
      throw new Error('Missing function parenthesis');
    }

    this.index++;

    switch (name) {
      case 'sin':
        return Math.sin(this.toRadians(parameter));
      case 'cos':
        return Math.cos(this.toRadians(parameter));
      case 'tan':
        return Math.tan(this.toRadians(parameter));
      case 'asin':
        return this.fromRadians(Math.asin(parameter));
      case 'acos':
        return this.fromRadians(Math.acos(parameter));
      case 'atan':
        return this.fromRadians(Math.atan(parameter));
      case 'ln':
        return Math.log(parameter);
      case 'log':
        return Math.log10(parameter);
      case 'sqrt':
        return Math.sqrt(parameter);
      default:
        throw new Error('Unsupported function');
    }
  }

  private toRadians(value: number): number {
    return this.degreeMode ? value * Math.PI / 180 : value;
  }

  private fromRadians(value: number): number {
    return this.degreeMode ? value * 180 / Math.PI : value;
  }

  private factorial(value: number): number {
    if (value < 0 || value !== Math.floor(value) || value > 170) {
      throw new Error('Invalid factorial');
    }

    let result: number = 1;
    for (let index: number = 2; index <= value; index++) {
      result *= index;
    }
    return result;
  }

  private isImplicitMultiplyStart(value: string): boolean {
    return value === '(' || value === 'π' || this.isLetter(value);
  }

  private isLetter(value: string): boolean {
    return (value >= 'a' && value <= 'z') ||
      (value >= 'A' && value <= 'Z');
  }

  private formatNumber(value: number): string {
    if (!Number.isFinite(value)) {
      return 'NaN';
    }

    if (value === 0) {
      return '0';
    }

    if (Math.abs(value) >= 1000000000000000 ||
      Math.abs(value) < 0.0000000000001) {
      return value.toExponential(12);
    }

    return Number(value.toPrecision(14)).toString();
  }
}

const scientificCalculator: ScientificExpressionCalculator =
  new ScientificExpressionCalculator();

@Entry
@Component
struct HomePage {
  // ==================== 状态变量 ====================
  @State inputValue: string = '';
  @State calValue: string = '';
  @State isScientificMode: boolean = false;
  @State isDegreeMode: boolean = true;
  @State memoryValue: number = 0;
  @State answerValue: string = '0';
  @State lastBtnIsEqu: boolean = false;
  @State isResultError: boolean = false;
  @State expressionHistory: string = '';

  private expressions: Array<string> = [];
  private uiContext = this.getUIContext();
  private historyModel: HistoryModel = HistoryModel.getInstance();
  private isHistoryReady: boolean = false;

  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('bottomRectHeight') bottomRectHeight: number = 0;

  // ==================== 生命周期 ====================
  aboutToAppear() {
    // 1. 检查历史模型是否已初始化
    this.checkHistoryReady();

    // 2. 恢复选中的历史记录
    this.restoreSelectedHistory();

    // 3. 恢复上次计算结果
    const answer: string | undefined =
      AppStorage.get<string>(ANSWER_STORAGE_KEY);

    if (answer !== undefined && answer.length > 0) {
      this.answerValue = answer;
    }
  }

  checkHistoryReady() {
    const ready = AppStorage.get<boolean>('historyModelReady');
    if (ready === true) {
      this.isHistoryReady = true;
      console.info('[HomePage] History model already ready');
    } else {
      this.initHistoryModel();
    }
  }

  async initHistoryModel() {
    try {
      const context = AppStorage.get<common.UIAbilityContext>('abilityContext');
      if (context) {
        await this.historyModel.init(context);
        this.isHistoryReady = true;
        AppStorage.setOrCreate('historyModelReady', true);
        console.info('[HomePage] History model initialized');
      } else {
        console.warn('[HomePage] No context available for history init');
      }
    } catch (error) {
      console.error('[HomePage] Init history failed: ' + JSON.stringify(error));
      this.isHistoryReady = false;
    }
  }

  // ==================== 保存历史记录 ====================
  async saveHistoryRecord(expression: string, result: string) {
    if (!this.isHistoryReady) {
      console.warn('[HomePage] History not ready, attempting to init...');
      await this.initHistoryModel();
      if (!this.isHistoryReady) {
        console.warn('[HomePage] History still not ready, skip saving');
        return;
      }
    }

    const mode = this.isScientificMode ? 'scientific' : 'basic';
    try {
      await this.historyModel.addHistory(expression, result, mode);
      console.info('[HomePage] History saved: ' + expression + ' = ' + result);
    } catch (error) {
      console.error('[HomePage] Save history failed: ' + JSON.stringify(error));
    }
  }

  // ==================== 构建UI ====================
  build() {
    Column() {
      this.TitleBar()
      this.DisplayPanel()
      this.CalculatorKeyboard()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F8')
  }

  // ==================== 标题栏 ====================
  @Builder
  TitleBar() {
    Row() {
      // 左侧标题
      Column() {
        Row() {
          Text('⚡')
            .fontSize(16)
            .margin({ right: 6 })
          Text(this.isScientificMode ? '科学' : '标准')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E')
        }

        Text(this.isScientificMode ? 'SCIENTIFIC MODE' : 'BASIC CALCULATOR')
          .fontSize(10)
          .fontColor('#9CA3AF')
          .fontWeight(FontWeight.Bold)
          .letterSpacing(1.5)
          .margin({ top: -2 })
      }
      .alignItems(HorizontalAlign.Start)

      // 右侧按钮
      Row({ space: 10 }) {
        Button() {
          Row({ space: 4 }) {
            Text(this.isScientificMode ? '🧪' : '📐')
              .fontSize(14)
            Text(this.isScientificMode ? '标准' : '科学')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
          }
        }
        .height(34)
        .padding({ left: 14, right: 14 })
        .fontColor('#0A59F7')
        .backgroundColor(this.isScientificMode ? '#E8F0FE' : '#F0F4FF')
        .borderRadius(10)
        .border({ width: 1, color: this.isScientificMode ? '#0A59F7' : '#D0D9E8' })
        .onClick(() => {
          this.isScientificMode = !this.isScientificMode;
          if (!this.isScientificMode) {
            this.isDegreeMode = true;
          }
        })

        Button() {
          Row({ space: 4 }) {
            Text('📋')
              .fontSize(14)
            Text('历史')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
          }
        }
        .height(34)
        .padding({ left: 14, right: 14 })
        .fontColor('#374151')
        .backgroundColor('#F0F0F0')
        .borderRadius(10)
        .border({ width: 1, color: '#E5E7EB' })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/HistoryPage'
          }).catch((error: Error) => {
            Logger.error('Open history page failed: ' + JSON.stringify(error));
          });
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.uiContext.px2vp(this.topRectHeight) + 4 })
  }

  // ==================== 显示面板 ====================
  @Builder
  DisplayPanel() {
    Column() {
      // 状态行
      Row() {
        Row({ space: 8 }) {
          Text(this.isScientificMode
            ? (this.isDegreeMode ? 'DEG' : 'RAD')
            : '')
            .fontSize(11)
            .fontColor('#0A59F7')
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#E8F0FE')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .visibility(this.isScientificMode ? Visibility.Visible : Visibility.None)

          Text(this.expressionHistory || ' ')
            .fontSize(12)
            .fontColor('#9CA3AF')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .layoutWeight(1)

        Text(this.expressions.length > 0 ? '●' : '○')
          .fontSize(10)
          .fontColor(this.expressions.length > 0 ? '#0A59F7' : '#9CA3AF')
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 4 })

      // 表达式
      Text(this.resultFormat(this.inputValue) || '0')
        .width('100%')
        .height(this.isScientificMode ? 50 : 60)
        .fontSize(this.isScientificMode ? 28 : 38)
        .fontColor(this.isResultError ? '#FF3B30' : '#1A1A2E')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.End)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .animation({ duration: 150, curve: Curve.EaseOut })

      Divider()
        .height(1)
        .color('#E8ECF4')
        .margin({ top: 8, bottom: 8 })

      // 结果行
      Row() {
        Text('=')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#9CA3AF')
          .margin({ right: 10 })

        Text(this.resultFormat(this.calValue) || '')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isResultError ? '#FF3B30' : '#0A59F7')
          .maxLines(1)
          .textAlign(TextAlign.End)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .height(36)
      .animation({ duration: 150, curve: Curve.EaseOut })
    }
    .width('100%')
    .height(this.isScientificMode ? 170 : 180)
    .padding({
      left: 22,
      right: 22,
      top: 14,
      bottom: 16
    })
    .margin({
      left: 14,
      right: 14,
      top: 6,
      bottom: 10
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.06)',
      offsetY: 4,
      offsetX: 0
    })
  }

  // ==================== 键盘容器 ====================
  @Builder
  CalculatorKeyboard() {
    Column() {
      // 科学模式函数键盘
      if (this.isScientificMode) {
        this.ScientificKeyboard()
      }

      // 主键盘
      Grid() {
        ForEach(
          this.getBasicKeys(),
          (key: string) => {
            GridItem() {
              this.KeyButton(key)
            }
            .height(this.isScientificMode ? 52 : 60)
          },
          (key: string, index: number) => key + '_' + index
        )
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(this.isScientificMode ? 8 : 10)
      .columnsGap(10)
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: 14,
        right: 14,
        top: this.isScientificMode ? 8 : 14,
        bottom: this.uiContext.px2vp(this.bottomRectHeight) + 18
      })
    }
    .width('100%')
    .layoutWeight(1)
    .borderRadius({ topLeft: 28, topRight: 28 })
    .backgroundColor('transparent')
  }

  // ==================== 按键组件 ====================
  @Builder
  KeyButton(key: string) {
    if (key === '0') {
      // 数字0占两列
      Column() {
        Text(key)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A2E')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(14)
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.04)',
        offsetY: 2
      })
      .onClick(() => {
        this.handleBasicKey(key);
      })
    } else {
      Column() {
        Text(key)
          .fontSize(this.getKeyFontSize(key))
          .fontWeight(this.getKeyFontWeight(key))
          .fontColor(this.getKeyTextColor(key))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.getKeyBackgroundColor(key))
      .borderRadius(14)
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.04)',
        offsetY: 2
      })
      .onClick(() => {
        this.handleBasicKey(key);
      })
    }
  }

  // ==================== 按键样式辅助函数 ====================
  getKeyBackgroundColor(key: string): string {
    const isOperator: boolean = this.isOperatorKey(key);
    const isNumber: boolean = key >= '1' && key <= '9';
    const isClear: boolean = key === 'C' || key === 'DEL';
    const isEqual: boolean = key === '=';
    const isSpecial: boolean = key === '%' || key === 'Ans' || key === '.';

    if (isEqual) return '#0A59F7';
    if (isOperator) return '#F0F4FF';
    if (isClear) return '#FFF0F0';
    if (isNumber) return '#FFFFFF';
    if (isSpecial) return '#F5F7FA';
    return '#FFFFFF';
  }

  getKeyTextColor(key: string): string {
    const isOperator: boolean = this.isOperatorKey(key);
    const isNumber: boolean = key >= '1' && key <= '9';
    const isClear: boolean = key === 'C' || key === 'DEL';
    const isEqual: boolean = key === '=';
    const isSpecial: boolean = key === '%' || key === 'Ans' || key === '.';

    if (isEqual) return '#FFFFFF';
    if (isOperator) return '#0A59F7';
    if (isClear) return '#FF3B30';
    if (isNumber) return '#1A1A2E';
    if (isSpecial) return '#374151';
    return '#1A1A2E';
  }

  getKeyFontSize(key: string): number {
    const isOperator: boolean = this.isOperatorKey(key);
    const isClear: boolean = key === 'C' || key === 'DEL';
    const isEqual: boolean = key === '=';
    const isSpecial: boolean = key === '%' || key === 'Ans' || key === '.';

    if (isEqual) return 28;
    if (isOperator) return 24;
    if (isClear) return 18;
    if (isSpecial) return 18;
    return 24;
  }

  getKeyFontWeight(key: string): FontWeight {
    return key === '=' ? FontWeight.Bold : FontWeight.Medium;
  }

  // ==================== 科学键盘 ====================
  @Builder
  ScientificKeyboard() {
    Grid() {
      ForEach(this.getScientificKeys(), (key: string) => {
        GridItem() {
          Text(key === 'DEG' ? (this.isDegreeMode ? 'DEG' : 'RAD') : key)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getScientificKeyColor(key))
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Center)
        }
        .height(38)
        .backgroundColor(this.getScientificKeyBgColor(key))
        .borderRadius(10)
        .shadow({
          radius: 2,
          color: 'rgba(0,0,0,0.03)',
          offsetY: 1
        })
        .onClick(() => {
          this.handleScientificKey(key);
        })
      }, (key: string, index: number) => key + '_' + index)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(6)
    .columnsGap(6)
    .width('100%')
    .height(188)
    .padding({
      left: 14,
      right: 14,
      top: 6,
      bottom: 8
    })
  }

  // ==================== 键盘数据 ====================
  getBasicKeys(): Array<string> {
    return [
      'C', 'DEL', '%', '÷',
      '7', '8', '9', '×',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', 'Ans', '='
    ];
  }

  getScientificKeys(): Array<string> {
    return [
      'DEG', '(', ')', 'MC', 'MR', 'M+',
      'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
      'ln', 'log', '√', 'x²', 'xʸ', '1/x',
      'π', 'e', 'n!', 'Ans', '%', 'M-',
    ];
  }

  // ==================== 颜色配置 ====================
  getScientificKeyColor(key: string): string {
    if (key === 'DEG' || key === 'π' || key === 'e' ||
      key === 'Ans' || key === 'M+' || key === 'M-' ||
      key === 'MC' || key === 'MR') {
      return '#0A59F7';
    }
    return '#374151';
  }

  getScientificKeyBgColor(key: string): string {
    if (key === 'DEG' || key === 'π' || key === 'e' ||
      key === 'Ans' || key === 'M+' || key === 'M-' ||
      key === 'MC' || key === 'MR') {
      return '#E8F0FE';
    }
    if (key === 'sin' || key === 'cos' || key === 'tan' ||
      key === 'asin' || key === 'acos' || key === 'atan' ||
      key === 'ln' || key === 'log' || key === '√') {
      return '#F5F7FA';
    }
    return '#F0F0F0';
  }

  isOperatorKey(value: string): boolean {
    return value === '+' || value === '-' ||
      value === '×' || value === '÷';
  }

  // ==================== 按键处理 ====================
  handleBasicKey(value: string) {
    this.isResultError = false;

    if (value === 'C') {
      this.clearCalculator();
    } else if (value === 'DEL') {
      this.deleteLastInput();
    } else if (value === '=') {
      this.calculateResult();
    } else if (value === 'Ans') {
      this.inputAnswer();
    } else if (this.isOperatorKey(value)) {
      this.inputOperator(value);
    } else {
      this.inputValueToken(value);
    }
  }

  handleScientificKey(value: string) {
    this.isResultError = false;

    if (value === 'DEG') {
      this.isDegreeMode = !this.isDegreeMode;
      this.refreshCalculationPreview();
      return;
    }

    if (value === 'MC') {
      this.memoryValue = 0;
      return;
    }

    if (value === 'MR') {
      this.appendToken(this.formatPlainNumber(this.memoryValue));
      this.refreshCalculationPreview();
      return;
    }

    if (value === 'M+' || value === 'M-') {
      const current: number = Number(this.calValue);
      if (!Number.isNaN(current)) {
        this.memoryValue = value === 'M+'
          ? this.memoryValue + current
          : this.memoryValue - current;
      }
      return;
    }

    if (value === 'π' || value === 'e') {
      this.appendToken(value);
    } else if (value === 'Ans') {
      this.inputAnswer();
      return;
    } else if (value === '√') {
      this.appendToken('sqrt(');
    } else if (value === 'x²') {
      this.appendToken('^2');
    } else if (value === 'xʸ') {
      this.appendToken('^');
    } else if (value === '1/x') {
      this.appendToken('1÷');
    } else if (value === 'n!') {
      this.appendToken('!');
    } else if (value === 'sin' || value === 'cos' ||
      value === 'tan' || value === 'asin' || value === 'acos' ||
      value === 'atan' || value === 'ln' || value === 'log') {
      this.appendToken(`${value}(`);
    } else if (value === '(' || value === ')' || value === '%') {
      this.appendToken(value);
    }

    this.lastBtnIsEqu = false;
    this.refreshCalculationPreview();
  }

  // ==================== 输入逻辑 ====================
  inputValueToken(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }

    if (this.lastBtnIsEqu) {
      this.expressions = [];
      this.inputValue = '';
      this.calValue = '';
      this.expressionHistory = '';
      this.lastBtnIsEqu = false;
    }

    const last: string = this.getLastToken();

    if (value >= '0' && value <= '9') {
      if (last === 'π' || last === 'e' || last === ')' ||
        last === '!' || last === '%') {
        this.expressions.push('×');
      }

      const currentLast: string = this.getLastToken();
      if (this.isNumberToken(currentLast) && !currentLast.includes('e')) {
        this.expressions[this.expressions.length - 1] += value;
      } else {
        this.expressions.push(value);
      }
    } else if (value === '.') {
      if (this.isNumberToken(last)) {
        if (!last.includes('.')) {
          this.expressions[this.expressions.length - 1] += '.';
        }
      } else {
        this.expressions.push('0.');
      }
    } else if (value === '%') {
      if (this.canApplyPostfix(last)) {
        this.expressions.push('%');
      }
    }

    this.refreshCalculationPreview();
  }

  inputOperator(value: string) {
    if (this.lastBtnIsEqu) {
      this.expressions = [this.answerValue];
      this.inputValue = this.answerValue;
      this.calValue = '';
      this.expressionHistory = '';
      this.lastBtnIsEqu = false;
    }

    const last: string = this.getLastToken();

    if (this.expressions.length === 0) {
      if (value === '-') {
        this.expressions.push('-');
      }
      this.formatInputValue();
      return;
    }

    if (this.isOperatorKey(last) || last === '^') {
      this.expressions[this.expressions.length - 1] = value;
    } else if (last === '(') {
      if (value === '-') {
        this.expressions.push('-');
      }
    } else {
      this.expressions.push(value);
    }

    this.refreshCalculationPreview();
  }

  inputAnswer() {
    if (this.lastBtnIsEqu) {
      this.expressions = [];
      this.inputValue = '';
      this.calValue = '';
      this.expressionHistory = '';
      this.lastBtnIsEqu = false;
    }

    const last: string = this.getLastToken();
    if (this.canApplyPostfix(last)) {
      this.expressions.push('×');
    }

    this.expressions.push(this.answerValue);
    this.refreshCalculationPreview();
  }

  appendToken(value: string) {
    if (this.lastBtnIsEqu) {
      this.expressions = [];
      this.inputValue = '';
      this.calValue = '';
      this.expressionHistory = '';
      this.lastBtnIsEqu = false;
    }

    const last: string = this.getLastToken();

    if ((value === '(' || value.endsWith('(') || value === 'π' ||
      value === 'e') && this.canApplyPostfix(last)) {
      this.expressions.push('×');
    }

    if (value === ')' && !this.hasOpenParenthesis()) {
      return;
    }

    if ((value === '!' || value === '%') &&
      !this.canApplyPostfix(last)) {
      return;
    }

    this.expressions.push(value);
  }

  // ==================== 操作函数 ====================
  deleteLastInput() {
    if (this.expressions.length === 0) {
      return;
    }

    this.lastBtnIsEqu = false;
    this.isResultError = false;
    const lastIndex: number = this.expressions.length - 1;
    const last: string = this.expressions[lastIndex];

    if (last.length > 1 && this.isNumberToken(last)) {
      this.expressions[lastIndex] = last.substring(0, last.length - 1);
    } else {
      this.expressions.pop();
    }

    this.refreshCalculationPreview();
  }

  clearCalculator() {
    this.expressions = [];
    this.inputValue = '';
    this.calValue = '';
    this.expressionHistory = '';
    this.lastBtnIsEqu = false;
    this.isResultError = false;
  }

  calculateResult() {
    if (this.expressions.length === 0) {
      return;
    }

    const expression: string = this.expressions.join('');
    const last: string = this.getLastToken();

    if (this.isOperatorKey(last) || last === '^' || last === '(' ||
      !this.hasBalancedParentheses()) {
      this.isResultError = true;
      this.calValue = this.getErrorText();
      return;
    }

    const result: string = scientificCalculator.calculate(
      expression,
      this.isDegreeMode
    );

    if (result === 'NaN') {
      this.isResultError = true;
      this.calValue = this.getErrorText();
      return;
    }

    // 保存计算结果
    this.answerValue = result;
    AppStorage.setOrCreate(ANSWER_STORAGE_KEY, result);

    // 保存表达式历史
    this.expressionHistory = expression;

    // 保存历史记录
    this.saveHistoryRecord(expression, result);

    // 更新显示
    this.inputValue = result;
    this.calValue = '';
    this.expressions = [result];
    this.lastBtnIsEqu = true;
    this.isResultError = false;
  }

  refreshCalculationPreview() {
    this.formatInputValue();

    const expression: string = this.expressions.join('');
    const last: string = this.getLastToken();

    if (expression.length === 0) {
      this.calValue = '';
      this.expressionHistory = '';
      return;
    }

    this.expressionHistory = expression;

    if (this.isOperatorKey(last) || last === '^' || last === '(' ||
      !this.hasBalancedParentheses()) {
      this.calValue = '';
      return;
    }

    const result: string = scientificCalculator.calculate(
      expression,
      this.isDegreeMode
    );

    this.calValue = result === 'NaN' ? '' : result;
  }

  // ==================== 历史记录（旧版兼容） ====================
  addHistoryRecord(
    expression: string,
    result: string,
    tokens: Array<string>
  ) {
    // 此方法保留用于兼容，实际使用 saveHistoryRecord
    this.saveHistoryRecord(expression, result);
  }

  loadHistory(): Array<HistoryRecord> {
    const data: string | undefined =
      AppStorage.get<string>(HISTORY_STORAGE_KEY);

    if (data === undefined || data.length === 0) {
      return [];
    }

    try {
      const records: Array<HistoryRecord> = JSON.parse(data) as Array<HistoryRecord>;
      return records.map((item: HistoryRecord) => {
        return new HistoryRecord(
          item.expression,
          item.result,
          item.tokens,
          item.time
        );
      });
    } catch (error) {
      Logger.error('Load history failed: ' + JSON.stringify(error));
      return [];
    }
  }

  restoreSelectedHistory() {
    const data: string | undefined =
      AppStorage.get<string>(SELECTED_HISTORY_KEY);

    if (data === undefined || data.length === 0) {
      return;
    }

    try {
      const record: HistoryRecord = JSON.parse(data) as HistoryRecord;
      this.expressions = Array.from(record.tokens);
      this.inputValue = this.expressions.map((item: string) => {
        return this.resultFormat(item);
      }).join('');
      this.calValue = record.result;
      this.answerValue = record.result;
      this.expressionHistory = record.expression;
      this.lastBtnIsEqu = false;
      AppStorage.setOrCreate(SELECTED_HISTORY_KEY, '');
    } catch (error) {
      Logger.error('Restore history failed: ' + JSON.stringify(error));
    }
  }

  // ==================== 工具函数 ====================
  getLastToken(): string {
    return this.expressions.length > 0
      ? this.expressions[this.expressions.length - 1]
      : '';
  }

  isNumberToken(value: string): boolean {
    if (value.length === 0) {
      return false;
    }
    return !Number.isNaN(Number(value));
  }

  canApplyPostfix(value: string): boolean {
    return this.isNumberToken(value) || value === ')' ||
      value === 'π' || value === 'e' || value === '!' || value === '%';
  }

  hasOpenParenthesis(): boolean {
    let count: number = 0;

    this.expressions.forEach((item: string) => {
      for (let index: number = 0; index < item.length; index++) {
        if (item.charAt(index) === '(') {
          count++;
        } else if (item.charAt(index) === ')') {
          count--;
        }
      }
    });

    return count > 0;
  }

  hasBalancedParentheses(): boolean {
    let count: number = 0;

    this.expressions.forEach((item: string) => {
      for (let index: number = 0; index < item.length; index++) {
        if (item.charAt(index) === '(') {
          count++;
        } else if (item.charAt(index) === ')') {
          count--;
        }
      }
    });

    return count === 0;
  }

  formatPlainNumber(value: number): string {
    if (!Number.isFinite(value)) {
      return '0';
    }

    if (value === 0) {
      return '0';
    }

    if (Math.abs(value) >= 1000000000000000 ||
      Math.abs(value) < 0.0000000000001) {
      return value.toExponential(12);
    }

    return Number(value.toPrecision(14)).toString();
  }

  resultFormat(value: string): string {
    if (value === undefined || value === null || value.length === 0) {
      return '';
    }

    let result: string = '';
    let numberBuffer: string = '';

    const flushNumber = (): void => {
      if (numberBuffer.length === 0) {
        return;
      }

      if (numberBuffer.includes('e') || numberBuffer.includes('E')) {
        result += numberBuffer;
        numberBuffer = '';
        return;
      }

      const parts: Array<string> = numberBuffer.split('.');
      let integerPart: string = parts[0];
      const decimalPart: string | undefined =
        parts.length > 1 ? parts[1] : undefined;

      let sign: string = '';
      if (integerPart.startsWith('-')) {
        sign = '-';
        integerPart = integerPart.substring(1);
      }

      let formattedInteger: string = '';
      for (let index: number = 0; index < integerPart.length; index++) {
        if (index > 0 && (integerPart.length - index) % 3 === 0) {
          formattedInteger += ',';
        }
        formattedInteger += integerPart.charAt(index);
      }

      result += sign + formattedInteger;
      if (decimalPart !== undefined) {
        result += '.' + decimalPart;
      }

      numberBuffer = '';
    };

    for (let index: number = 0; index < value.length; index++) {
      const item: string = value.charAt(index);

      if ((item >= '0' && item <= '9') || item === '.' ||
        item === 'e' || item === 'E') {
        numberBuffer += item;
      } else {
        flushNumber();
        result += item;
      }
    }

    flushNumber();
    return result;
  }

  getErrorText(): string {
    return '错误';
  }

  formatInputValue() {
    this.inputValue = this.expressions.map((item: string) => {
      return this.resultFormat(item);
    }).join('');
  }
}