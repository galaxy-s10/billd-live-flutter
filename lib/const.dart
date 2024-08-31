import 'dart:ui';

const localIp = '192.168.1.104';
const appTitle = 'billd直播';
const themeColor = Color.fromRGBO(255, 215, 0, 1);

// const axiosBaseUrl = 'https://live-api.hsslive.cn';
// const websocketUrl = 'wss://srs-pull.hsslive.cn';
const axiosBaseUrl = 'http://$localIp:4300';
const websocketUrl = 'ws://$localIp:4300';
const axiosTimeoutSeconds = 5;

const normalVideoRatio = 16 / 9;
// 纵横比
const normalAspectRatio = 9 / 16; // 0.5625
