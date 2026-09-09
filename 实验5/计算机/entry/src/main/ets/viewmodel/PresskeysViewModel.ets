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

import { PressKeyItem } from './PressKeysItem';

export class PressKeysViewModel {
  /**
   * 普通模式键盘数据 - 5行×4列布局
   * 第1行：C ÷ × ⌫
   * 第2行：7 8 9 -
   * 第3行：4 5 6 +
   * 第4行：1 2 3 =
   * 第5行：% 0 . （右边留空）
   */
  getPressKeys(): Array<Array<PressKeyItem>> {
    return [
      // 第1行: C ÷ × ⌫
      [
        new PressKeyItem(0, '28vp', '37vp', 'C', $r('app.media.clean')),
        new PressKeyItem(2, '42vp', '56vp', '÷', $r('app.media.ic_div')),
        new PressKeyItem(2, '42vp', '56vp', '×', $r('app.media.ic_mul')),
        new PressKeyItem(0, '30.48vp', '20vp', '⌫', $r('app.media.ic_delete'))
      ],
      // 第2行: 7 8 9 -
      [
        new PressKeyItem(1, '26vp', '35vp', '7'),
        new PressKeyItem(1, '26vp', '35vp', '8'),
        new PressKeyItem(1, '26vp', '35vp', '9'),
        new PressKeyItem(2, '42vp', '56vp', '-', $r('app.media.ic_min'))
      ],
      // 第3行: 4 5 6 +
      [
        new PressKeyItem(1, '26vp', '35vp', '4'),
        new PressKeyItem(1, '26vp', '35vp', '5'),
        new PressKeyItem(1, '26vp', '35vp', '6'),
        new PressKeyItem(2, '42vp', '56vp', '+', $r('app.media.ic_add'))
      ],
      // 第4行: 1 2 3 =
      [
        new PressKeyItem(1, '26vp', '35vp', '1'),
        new PressKeyItem(1, '26vp', '35vp', '2'),
        new PressKeyItem(1, '26vp', '35vp', '3'),
        new PressKeyItem(3, '42vp', '56vp', '=', $r('app.media.ic_equ'))
      ],
      // 第5行: % 0 . （右边留空）
      [
        new PressKeyItem(1, '26vp', '35vp', '%'),
        new PressKeyItem(1, '58vp', '35vp', '0'),
        new PressKeyItem(1, '26vp', '35vp', '.'),
        new PressKeyItem(4, '26vp', '35vp', '')  // 空占位
      ]
    ];
  }

  /**
   * 科学模式键盘数据（函数区 + 数字区）
   */
  getScientificKeys(): Array<Array<PressKeyItem>> {
    return [
      [
        new PressKeyItem(4, '42vp', '56vp', 'sin'),
        new PressKeyItem(4, '42vp', '56vp', 'cos'),
        new PressKeyItem(4, '42vp', '56vp', 'tan'),
        new PressKeyItem(4, '42vp', '56vp', 'log')
      ],
      [
        new PressKeyItem(4, '42vp', '56vp', 'ln'),
        new PressKeyItem(4, '42vp', '56vp', '√'),
        new PressKeyItem(4, '42vp', '56vp', 'x²'),
        new PressKeyItem(4, '42vp', '56vp', 'x³')
      ],
      [
        new PressKeyItem(4, '42vp', '56vp', 'xⁿ'),
        new PressKeyItem(4, '42vp', '56vp', '1/x'),
        new PressKeyItem(4, '42vp', '56vp', 'x!'),
        new PressKeyItem(4, '42vp', '56vp', '(')
      ],
      [
        new PressKeyItem(4, '42vp', '56vp', 'π'),
        new PressKeyItem(4, '42vp', '56vp', 'e'),
        new PressKeyItem(4, '42vp', '56vp', ')'),
        new PressKeyItem(0, '30.48vp', '20vp', '⌫', $r('app.media.ic_delete'))
      ]
    ];
  }

  /**
   * 科学模式数字行
   */
  getScientificNumberKeys(): Array<Array<PressKeyItem>> {
    return [
      [
        new PressKeyItem(1, '26vp', '35vp', '7'),
        new PressKeyItem(1, '26vp', '35vp', '8'),
        new PressKeyItem(1, '26vp', '35vp', '9'),
        new PressKeyItem(2, '42vp', '56vp', '÷', $r('app.media.ic_div'))
      ],
      [
        new PressKeyItem(1, '26vp', '35vp', '4'),
        new PressKeyItem(1, '26vp', '35vp', '5'),
        new PressKeyItem(1, '26vp', '35vp', '6'),
        new PressKeyItem(2, '42vp', '56vp', '×', $r('app.media.ic_mul'))
      ],
      [
        new PressKeyItem(1, '26vp', '35vp', '1'),
        new PressKeyItem(1, '26vp', '35vp', '2'),
        new PressKeyItem(1, '26vp', '35vp', '3'),
        new PressKeyItem(2, '42vp', '56vp', '-', $r('app.media.ic_min'))
      ],
      [
        new PressKeyItem(1, '58vp', '35vp', '0'),
        new PressKeyItem(1, '26vp', '35vp', '.'),
        new PressKeyItem(2, '42vp', '56vp', '+', $r('app.media.ic_add')),
        new PressKeyItem(3, '42vp', '56vp', '=', $r('app.media.ic_equ'))
      ]
    ];
  }
}

let keysModel = new PressKeysViewModel();
export default keysModel as PressKeysViewModel;