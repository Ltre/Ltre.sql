
SET FOREIGN_KEY_CHECKS=0;


CREATE TABLE `game` (
  `game_id` bigint(11) NOT NULL AUTO_INCREMENT,
  `game_title` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `age_rating` int(32) NOT NULL COMMENT '年龄等级限制，采用PEGI标准，例如 3, 7, 12, 16, 18，参考https://www.kingston.com.cn/cn/blog/gaming/understanding-video-games-age-ratings-esrb-pegi ',
  `release_date` date DEFAULT NULL,
  `developer` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`game_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE `gift` (
  `gift_id` bigint(11) NOT NULL,
  `gift_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` bigint(11) NOT NULL COMMENT 'ParroCoin价格',
  PRIMARY KEY (`gift_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



CREATE TABLE `gift_donate` (
  `donate_id` bigint(20) NOT NULL,
  `user_id` bigint(11) NOT NULL COMMENT '送礼人ID',
  `stream_id` bigint(20) NOT NULL COMMENT '直播会话ID',
  `gift_id` bigint(11) NOT NULL,
  `donate_time` datetime NOT NULL COMMENT '送礼时间',
  `donate_num` int(11) NOT NULL COMMENT '在同一时间点，送同个礼物个数，例如 “刷了火箭x99”',
  PRIMARY KEY (`donate_id`),
  KEY `fk_donate_user` (`user_id`),
  KEY `fk_donate_stream` (`stream_id`),
  KEY `fk_donate_gift` (`gift_id`),
  CONSTRAINT `fk_donate_gift` FOREIGN KEY (`gift_id`) REFERENCES `gift` (`gift_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_donate_stream` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_donate_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='直播送礼记录';




CREATE TABLE `income` (
  `income_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL COMMENT '被增加收入的用户ID',
  `income_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收入来源类型，值有：DONATE（送礼）、LIVE_ONLINE_DURATION（直播在线观看时长）、RECHARGE（充值，严格来讲，这个能算文档中提到的收入，自己考虑加入这个类型是否会被老师扣分）',
  `donate_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '送礼记录ID（当income_type=DONATE时有效），0表示此条记录并非送礼收入所得',
  `visit_id` bigint(20) NOT NULL DEFAULT '0' COMMENT 'user_id本人直播被在线观看的记录ID （仅当income_type=LIVE_ONLINE_DURATION时有效），0表示此条记录并非时长收入所得',
  `recharge_id` bigint(20) NOT NULL COMMENT '充值记录ID（当income_type=RECHARGE时有效），0表示此条记录并非充值所得',
  `income_coin` bigint(20) NOT NULL COMMENT '收入的coin数  （对于时长计算收入的定义，就不另外建立规则表了，自行脑补过程）',
  `income_time` datetime NOT NULL COMMENT '产生此条收入记录的时间',
  PRIMARY KEY (`income_id`),
  KEY `fk_income_user` (`user_id`),
  KEY `fk_income_donate` (`donate_id`),
  KEY `fk_income_visit` (`visit_id`),
  KEY `fk_income_recharge` (`recharge_id`),
  CONSTRAINT `fk_income_donate` FOREIGN KEY (`donate_id`) REFERENCES `gift_donate` (`donate_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_income_recharge` FOREIGN KEY (`recharge_id`) REFERENCES `recharge` (`recharge_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_income_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_income_visit` FOREIGN KEY (`visit_id`) REFERENCES `stream_visit` (`visit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ParroCoin收入记录(流水)，类型支持：收礼/观看时长/充值';




CREATE TABLE `recharge` (
  `recharge_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `coin_num` bigint(20) NOT NULL COMMENT '购买ParrorCoin个数',
  `money` bigint(20) NOT NULL COMMENT '购买所花费法币金额，单位以法币最低单位来计，例如人民币用(分)',
  `recharge_time` datetime NOT NULL,
  PRIMARY KEY (`recharge_id`),
  KEY `fk_recharge_user` (`user_id`),
  CONSTRAINT `fk_recharge_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值购买coin的记录';



CREATE TABLE `stream` (
  `stream_id` bigint(20) NOT NULL,
  `stream_title` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime NOT NULL COMMENT '实际开播时间',
  `end_time` datetime NOT NULL COMMENT '实际下播时间',
  `plan_start_time` datetime NOT NULL COMMENT '计划开播时间',
  `plan_end_time` datetime NOT NULL COMMENT '计划下播时间',
  `record_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '直播结束后，提供的录播观看地址（NOTE!!!!!!! 这个是额外加的字段，文档里没具体提到）',
  PRIMARY KEY (`stream_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='一次直播会话';



CREATE TABLE `stream_game_bind` (
  `stream_id` bigint(20) NOT NULL,
  `game_id` bigint(11) NOT NULL,
  KEY `fk_sg_game` (`game_id`),
  KEY `fk_sg_stream` (`stream_id`) USING BTREE,
  CONSTRAINT `fk_sg_game` FOREIGN KEY (`game_id`) REFERENCES `game` (`game_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sg_stream` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='直播会话与游戏绑定关系';



CREATE TABLE `stream_streamer_bind` (
  `stream_id` bigint(20) NOT NULL COMMENT '直播会话ID',
  `streamer_id` bigint(11) NOT NULL COMMENT '参与直播会话的用户ID，等价于user表的user_id，别的表同名字段不再赘述',
  KEY `fk_ss_stream` (`stream_id`),
  KEY `fk_ss_user` (`streamer_id`),
  CONSTRAINT `fk_ss_stream` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ss_user` FOREIGN KEY (`streamer_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='直播会话与主播的绑定关系\r\n（表名太难取了，在文档stream session record例表的设定下以stream的基础命名，会拗口，有需要你自己调整）';



CREATE TABLE `stream_visit` (
  `visit_id` bigint(20) NOT NULL,
  `stream_id` bigint(20) NOT NULL COMMENT '直播会话ID',
  `user_id` bigint(11) NOT NULL COMMENT '观看者',
  `start_time` datetime NOT NULL COMMENT '观看开始时间',
  `end_time` datetime NOT NULL COMMENT '观看结束时间',
  `is_online` tinyint(4) NOT NULL COMMENT '是否在线看直播：1-在线直播；0-离线录播',
  PRIMARY KEY (`visit_id`),
  KEY `fk_sv_stream` (`stream_id`),
  KEY `fk_sv_user` (`user_id`),
  CONSTRAINT `fk_sv_stream` FOREIGN KEY (`stream_id`) REFERENCES `stream` (`stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sv_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户观看直播/录播记录';



CREATE TABLE `user` (
  `user_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `nickname` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idcard` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '身份证或护照号码',
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '姓名',
  `birth_date` date DEFAULT NULL,
  `email` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `reg_time` datetime NOT NULL COMMENT '注册时间',
  `balance` int(11) NOT NULL DEFAULT '0' COMMENT 'ParroCoin的余额',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `nickname` (`nickname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
