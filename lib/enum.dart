// websocket消息类型
const wsMsgTypeEnum = {
  'connect': 'connect',

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

  'batchSendOffer': 'batchSendOffer',
  'nativeWebRtcOffer': 'nativeWebRtcOffer',
  'nativeWebRtcAnswer': 'nativeWebRtcAnswer',
  'nativeWebRtcCandidate': 'nativeWebRtcCandidate',
};

// 直播间类型
const liveRoomTypeEnum = {
  /** 系统推流 */
  'system': 1,
  /** 主播使用srs推流 */
  "srs": 2,
  /** 主播使用obs/ffmpeg推流 */
  'obs': 3,
  /** 主播使用webrtc推流，直播 */
  'wertc_live': 4,
  /** 主播使用webrtc推流，会议，实现一 */
  'wertc_meeting_one': 5,
  /** 主播使用webrtc推流，会议，实现二 */
  'wertc_meeting_two': 6,
  /** 主播使用msr推流 */
  'msr': 7,
  /** 主播打pk */
  'pk': 8,
  /** 主播使用腾讯云css推流 */
  'tencentcloud_css': 9,
  /** 主播使用腾讯云css推流打pk */
  'tencentcloud_css_pk': 10,
  /** 转推b站 */
  'forward_bilibili': 11,
  /** 转推虎牙 */
  'forward_huya': 12,
  /** 转推斗鱼 */
  'forward_douyu': 13,
  /** 转推斗鱼 */
  'forward_douyin': 14,
  /** 转推斗鱼 */
  'forward_kuaishou': 15,
  /** 转推斗鱼 */
  'forward_xiaohongshu': 16,
  /** 转推所有 */
  'forward_all': 17,
};

const clientEnvEnum = {
  'android': 0,
  'ios': 1,
  'ipad': 2,
  'web': 3,
  'web_mobile': 4,
  'web_pc': 5,
  'windows': 6,
  'macos': 7,
};

const clientAppEnum = {
  'billd_live_android_app': 0,
  'billd_live_ios_app': 1,
  'billd_live_web': 2,
  'billd_live_admin': 3,
};
