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

/**
 * Common constants for all features.
 */
export class CommonConstants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';
  /**
   * Operator Collection.
   */
  static readonly OPERATORS: string = '+-×÷';
  /**
   * Operators with high precedence.
   */
  static readonly OPERATORS_PRIORITY: string = '×÷';
  /**
   * Addition.
   */
  static readonly ADD: string = '+';
  /**
   * Minus.
   */
  static readonly MIN: string = '-';
  /**
   * Multiplication.
   */
  static readonly MUL: string = '×';
  /**
   * Division.
   */
  static readonly DIV: string = '÷';
  /**
   * Percent sign.
   */
  static readonly PERCENT_SIGN: string = '%';
  /**
   * Decimal point.
   */
  static readonly DOTS: string = '.';
  /**
   * Number two.
   */
  static readonly TWO: number = 2;
  /**
   * Digit ten.
   */
  static readonly TEN: number = 10;
  /**
   * One hundred.
   */
  static readonly ONE_HUNDRED: string = '100';
  /**
   * Display Maximum Length of Large Fonts.
   */
  static readonly INPUT_LENGTH_MAX: number = 9;
  /**
   * Subscript is two.
   */
  static readonly INDEX_TWO: number = 2;
  /**
   * Maximum length of a single digit.
   */
  static readonly NUM_MAX_LEN: number = 16;
  /**
   * Letter e.
   */
  static readonly E: string = 'e';
  /**
   * String Zero.
   */
  static readonly ZERO: string = '0';
  /**
   * zero point.
   */
  static readonly ZERO_DOTS: string = '0.';

  static readonly FONT_SIZE_12 = 12;
  static readonly FONT_SIZE_16 = 16;
  static readonly FONT_SIZE_20 = 20;
  static readonly FONT_SIZE_24 = 24;
  static readonly FONT_SIZE_32 = 32;

  static readonly FONT_WEIGHT_MEDIUM = FontWeight.Medium;
  static readonly FONT_WEIGHT_REGULAR = FontWeight.Regular;
  static readonly FONT_WEIGHT_LIGHTER = FontWeight.Lighter;
  static readonly FONT_WEIGHT_BOLD = FontWeight.Bold;
  static readonly FONT_WEIGHT_BOLDER = FontWeight.Bolder;
  static readonly FONT_WEIGHT_SEMIBOLD = 'SemiBold';

  static readonly FONT_FAMILY_1 = 'HarmonyOS Sans';

  static readonly COMPONENT_BAY_SIZE_4 = 4;
  static readonly COMPONENT_BAY_SIZE_8 = 8;
  static readonly COMPONENT_BAY_SIZE_16 = 16;
  static readonly COMPONENT_BAY_SIZE_36 = 36;

  static readonly BORDER_RADIUS_0 = 0;
  static readonly BORDER_RADIUS_16 = 16;
  static readonly BORDER_RADIUS_20 = 20;

  static readonly WIDTH_36 = 36;
  static readonly WIDTH_98 = 98;
  static readonly WIDTH_99 = 99;
  static readonly WIDTH_296 = 296;

  static readonly HEIGHT_20 = 20;
  static readonly HEIGHT_79 = 79;
  static readonly HEIGHT_80 = 80;
  static readonly HEIGHT_320 = 320;

  // ========== 科学计算相关 ==========
  static readonly SCI_FUNCS: string[] = ['sin', 'cos', 'tan', 'log', 'ln', '√', 'x²', 'x³', 'xⁿ', '1/x', 'x!'];
  static readonly PI: string = 'π';
  static readonly PI_VALUE: number = 3.141592653589793;
  static readonly EULER: string = 'e';
  static readonly EULER_VALUE: number = 2.718281828459045;
  static readonly LEFT_PAREN: string = '(';
  static readonly RIGHT_PAREN: string = ')';
  static readonly MODE_BASIC: string = 'basic';
  static readonly MODE_SCIENTIFIC: string = 'scientific';
  static readonly POWER: string = '^';

  // ========== 路由路径 ==========
  static readonly ROUTE_HISTORY: string = 'pages/HistoryPage';
}

/**
 * Symbol value.
 */
export enum Symbol {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷',
  CLEAN = 'C',
  DEL = 'del',
  EQU = '=',
  SIN = 'sin',
  COS = 'cos',
  TAN = 'tan',
  LOG = 'log',
  LN = 'ln',
  SQRT = '√',
  SQUARE = 'x²',
  CUBE = 'x³',
  POWER = 'xⁿ',
  RECIPROCAL = '1/x',
  FACTORIAL = 'x!',
  PI = 'π',
  EULER = 'e'
}

/**
 * Operator Precedence Enumeration.
 */
export enum Priority {
  HIGH = 2,
  MEDIUM = 1,
  LOW = 0
}

/**
 * Enumerated value: addition, subtraction, multiplication, and division.
 */
export enum SymbolicEnumeration {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷'
}