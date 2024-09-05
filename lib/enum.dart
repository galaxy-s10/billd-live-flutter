// websocket消息类型
const wsMsgTypeEnum = {
  // 用户进入聊天
  'join': 'join',

  // 用户进入聊天完成
  'joined': 'joined',

  // 用户进入聊天
  'otherJoin': 'otherJoin',

  // 用户退出聊天
  'leave': 'leave',

  // 用户退出聊天完成
  'leaved': 'leaved',

  // 当前所有在线用户
  'liveUser': 'liveUser',

  // 用户发送消息
  'message': 'message',

  // 房间正在直播
  'roomLiving': 'roomLiving',
};

// 直播间类型
const liveRoomTypeEnum = {
  /** 系统推流 */
  'system': 0,
  /** 主播使用srs推流 */
  "srs": 1,
  /** 主播使用obs/ffmpeg推流 */
  'obs': 2,
  /** 主播使用webrtc推流，直播 */
  'wertc_live': 3,
  /** 主播使用webrtc推流，会议，实现一 */
  'wertc_meeting_one': 4,
  /** 主播使用webrtc推流，会议，实现二 */
  'wertc_meeting_two': 5,
  /** 主播使用msr推流 */
  'msr': 6,
  /** 主播打pk */
  'pk': 7,
  /** 主播使用腾讯云css推流 */
  'tencent_css': 8,
  /** 主播使用腾讯云css推流打pk */
  'tencent_css_pk': 9,
  /** 转推b站 */
  'forward_bilibili': 10,
  /** 转推虎牙 */
  'forward_huya': 11,
  /** 转推所有 */
  'forward_all': 12,
};

// 是否使用cdn
const liveRoomUseCDNEnum = {
  /** 使用cdn */
  'yes': 0,
  /** 不使用cdn */
  'no': 1,
};
