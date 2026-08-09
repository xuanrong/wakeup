/// 古诗库（公版，作者逝世超 50 年，无版权风险）。
/// 每首含 id / 标题 / 作者 / 朝代 / 正文数组 / 难度。
/// 正文标点统一全角（，。！？），比对规则见设计文档 3.3。
library;

class Poem {
  const Poem({
    required this.id,
    required this.title,
    required this.author,
    required this.dynasty,
    required this.lines,
    required this.difficulty,
  });

  final String id;
  final String title;
  final String author;
  final String dynasty;

  /// 正文诗句（不含标题/作者）。
  final List<String> lines;

  /// 1=短（四句） 2=中（八句） 3=长（更多句）。
  final int difficulty;

  String get fullText => lines.join();

  factory Poem.fromJson(Map<String, dynamic> json) => Poem(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        dynasty: json['dynasty'] as String,
        lines: (json['lines'] as List).cast<String>(),
        difficulty: json['difficulty'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'dynasty': dynasty,
        'lines': lines,
        'difficulty': difficulty,
      };
}

class PoemBank {
  PoemBank._();

  static const List<Poem> poems = [
    // ---------- 难度 1：四句绝句 ----------
    Poem(
      id: 'jueju_001',
      title: '静夜思',
      author: '李白',
      dynasty: '唐',
      difficulty: 1,
      lines: ['床前明月光，', '疑是地上霜。', '举头望明月，', '低头思故乡。'],
    ),
    Poem(
      id: 'jueju_002',
      title: '春晓',
      author: '孟浩然',
      dynasty: '唐',
      difficulty: 1,
      lines: ['春眠不觉晓，', '处处闻啼鸟。', '夜来风雨声，', '花落知多少。'],
    ),
    Poem(
      id: 'jueju_003',
      title: '登鹳雀楼',
      author: '王之涣',
      dynasty: '唐',
      difficulty: 1,
      lines: ['白日依山尽，', '黄河入海流。', '欲穷千里目，', '更上一层楼。'],
    ),
    Poem(
      id: 'jueju_004',
      title: '悯农',
      author: '李绅',
      dynasty: '唐',
      difficulty: 1,
      lines: ['锄禾日当午，', '汗滴禾下土。', '谁知盘中餐，', '粒粒皆辛苦。'],
    ),
    Poem(
      id: 'jueju_005',
      title: '咏鹅',
      author: '骆宾王',
      dynasty: '唐',
      difficulty: 1,
      lines: ['鹅，鹅，鹅，', '曲项向天歌。', '白毛浮绿水，', '红掌拨清波。'],
    ),
    Poem(
      id: 'jueju_006',
      title: '寻隐者不遇',
      author: '贾岛',
      dynasty: '唐',
      difficulty: 1,
      lines: ['松下问童子，', '言师采药去。', '只在此山中，', '云深不知处。'],
    ),
    Poem(
      id: 'jueju_007',
      title: '相思',
      author: '王维',
      dynasty: '唐',
      difficulty: 1,
      lines: ['红豆生南国，', '春来发几枝。', '愿君多采撷，', '此物最相思。'],
    ),
    Poem(
      id: 'jueju_008',
      title: '江雪',
      author: '柳宗元',
      dynasty: '唐',
      difficulty: 1,
      lines: ['千山鸟飞绝，', '万径人踪灭。', '孤舟蓑笠翁，', '独钓寒江雪。'],
    ),
    Poem(
      id: 'jueju_009',
      title: '鹿柴',
      author: '王维',
      dynasty: '唐',
      difficulty: 1,
      lines: ['空山不见人，', '但闻人语响。', '返景入深林，', '复照青苔上。'],
    ),
    Poem(
      id: 'jueju_010',
      title: '塞下曲',
      author: '卢纶',
      dynasty: '唐',
      difficulty: 1,
      lines: ['月黑雁飞高，', '单于夜遁逃。', '欲将轻骑逐，', '大雪满弓刀。'],
    ),
    Poem(
      id: 'jueju_011',
      title: '九月九日忆山东兄弟',
      author: '王维',
      dynasty: '唐',
      difficulty: 1,
      lines: ['独在异乡为异客，', '每逢佳节倍思亲。', '遥知兄弟登高处，', '遍插茱萸少一人。'],
    ),
    Poem(
      id: 'jueju_012',
      title: '望庐山瀑布',
      author: '李白',
      dynasty: '唐',
      difficulty: 1,
      lines: ['日照香炉生紫烟，', '遥看瀑布挂前川。', '飞流直下三千尺，', '疑是银河落九天。'],
    ),

    // ---------- 难度 2：八句律诗 ----------
    Poem(
      id: 'lvshi_001',
      title: '春望',
      author: '杜甫',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '国破山河在，', '城春草木深。', '感时花溅泪，', '恨别鸟惊心。',
        '烽火连三月，', '家书抵万金。', '白头搔更短，', '浑欲不胜簪。',
      ],
    ),
    Poem(
      id: 'lvshi_002',
      title: '望岳',
      author: '杜甫',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '岱宗夫如何？', '齐鲁青未了。', '造化钟神秀，', '阴阳割昏晓。',
        '荡胸生曾云，', '决眦入归鸟。', '会当凌绝顶，', '一览众山小。',
      ],
    ),
    Poem(
      id: 'lvshi_003',
      title: '山居秋暝',
      author: '王维',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '空山新雨后，', '天气晚来秋。', '明月松间照，', '清泉石上流。',
        '竹喧归浣女，', '莲动下渔舟。', '随意春芳歇，', '王孙自可留。',
      ],
    ),
    Poem(
      id: 'lvshi_004',
      title: '使至塞上',
      author: '王维',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '单车欲问边，', '属国过居延。', '征蓬出汉塞，', '归雁入胡天。',
        '大漠孤烟直，', '长河落日圆。', '萧关逢候骑，', '都护在燕然。',
      ],
    ),
    Poem(
      id: 'lvshi_005',
      title: '过故人庄',
      author: '孟浩然',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '故人具鸡黍，', '邀我至田家。', '绿树村边合，', '青山郭外斜。',
        '开轩面场圃，', '把酒话桑麻。', '待到重阳日，', '还来就菊花。',
      ],
    ),
    Poem(
      id: 'lvshi_006',
      title: '钱塘湖春行',
      author: '白居易',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '孤山寺北贾亭西，', '水面初平云脚低。', '几处早莺争暖树，', '谁家新燕啄春泥。',
        '乱花渐欲迷人眼，', '浅草才能没马蹄。', '最爱湖东行不足，', '绿杨阴里白沙堤。',
      ],
    ),
    Poem(
      id: 'lvshi_007',
      title: '送杜少府之任蜀州',
      author: '王勃',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '城阙辅三秦，', '风烟望五津。', '与君离别意，', '同是宦游人。',
        '海内存知己，', '天涯若比邻。', '无为在歧路，', '儿女共沾巾。',
      ],
    ),
    Poem(
      id: 'lvshi_008',
      title: '次北固山下',
      author: '王湾',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '客路青山外，', '行舟绿水前。', '潮平两岸阔，', '风正一帆悬。',
        '海日生残夜，', '江春入旧年。', '乡书何处达，', '归雁洛阳边。',
      ],
    ),
    Poem(
      id: 'lvshi_009',
      title: '黄鹤楼',
      author: '崔颢',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '昔人已乘黄鹤去，', '此地空余黄鹤楼。', '黄鹤一去不复返，', '白云千载空悠悠。',
        '晴川历历汉阳树，', '芳草萋萋鹦鹉洲。', '日暮乡关何处是，', '烟波江上使人愁。',
      ],
    ),
    Poem(
      id: 'lvshi_010',
      title: '登高',
      author: '杜甫',
      dynasty: '唐',
      difficulty: 2,
      lines: [
        '风急天高猿啸哀，', '渚清沙白鸟飞回。', '无边落木萧萧下，', '不尽长江滚滚来。',
        '万里悲秋常作客，', '百年多病独登台。', '艰难苦恨繁霜鬓，', '潦倒新停浊酒杯。',
      ],
    ),

    // ---------- 难度 3：长诗 ----------
    Poem(
      id: 'chang_001',
      title: '将进酒',
      author: '李白',
      dynasty: '唐',
      difficulty: 3,
      lines: [
        '君不见黄河之水天上来，', '奔流到海不复回。', '君不见高堂明镜悲白发，',
        '朝如青丝暮成雪。', '人生得意须尽欢，', '莫使金樽空对月。',
        '天生我材必有用，', '千金散尽还复来。', '烹羊宰牛且为乐，', '会须一饮三百杯。',
      ],
    ),
    Poem(
      id: 'chang_002',
      title: '蜀道难',
      author: '李白',
      dynasty: '唐',
      difficulty: 3,
      lines: [
        '噫吁嚱，危乎高哉！', '蜀道之难，难于上青天！', '蚕丛及鱼凫，', '开国何茫然。',
        '尔来四万八千岁，', '不与秦塞通人烟。', '西当太白有鸟道，', '可以横绝峨眉巅。',
        '地崩山摧壮士死，', '然后天梯石栈相钩连。',
      ],
    ),
    Poem(
      id: 'chang_003',
      title: '琵琶行',
      author: '白居易',
      dynasty: '唐',
      difficulty: 3,
      lines: [
        '浔阳江头夜送客，', '枫叶荻花秋瑟瑟。', '主人下马客在船，', '举酒欲饮无管弦。',
        '醉不成欢惨将别，', '别时茫茫江浸月。', '忽闻水上琵琶声，', '主人忘归客不发。',
        '寻声暗问弹者谁？', '琵琶声停欲语迟。',
      ],
    ),
    Poem(
      id: 'chang_004',
      title: '长恨歌',
      author: '白居易',
      dynasty: '唐',
      difficulty: 3,
      lines: [
        '汉皇重色思倾国，', '御宇多年求不得。', '杨家有女初长成，', '养在深闺人未识。',
        '天生丽质难自弃，', '一朝选在君王侧。', '回眸一笑百媚生，', '六宫粉黛无颜色。',
        '春寒赐浴华清池，', '温泉水滑洗凝脂。',
      ],
    ),
    Poem(
      id: 'chang_005',
      title: '水调歌头',
      author: '苏轼',
      dynasty: '宋',
      difficulty: 3,
      lines: [
        '明月几时有？', '把酒问青天。', '不知天上宫阙，', '今夕是何年。',
        '我欲乘风归去，', '又恐琼楼玉宇，', '高处不胜寒。', '起舞弄清影，', '何似在人间。',
        '转朱阁，低绮户，照无眠。', '不应有恨，何事长向别时圆？',
      ],
    ),
    Poem(
      id: 'chang_006',
      title: '念奴娇·赤壁怀古',
      author: '苏轼',
      dynasty: '宋',
      difficulty: 3,
      lines: [
        '大江东去，', '浪淘尽，', '千古风流人物。', '故垒西边，', '人道是，',
        '三国周郎赤壁。', '乱石穿空，', '惊涛拍岸，', '卷起千堆雪。',
        '江山如画，一时多少豪杰。',
      ],
    ),
    Poem(
      id: 'chang_007',
      title: '滕王阁序',
      author: '王勃',
      dynasty: '唐',
      difficulty: 3,
      lines: [
        '豫章故郡，', '洪都新府。', '星分翼轸，', '地接衡庐。', '襟三江而带五湖，',
        '控蛮荆而引瓯越。', '物华天宝，龙光射牛斗之墟；', '人杰地灵，徐孺下陈蕃之榻。',
        '雄州雾列，', '俊采星驰。',
      ],
    ),
    Poem(
      id: 'chang_008',
      title: '岳阳楼记',
      author: '范仲淹',
      dynasty: '宋',
      difficulty: 3,
      lines: [
        '庆历四年春，', '滕子京谪守巴陵郡。', '越明年，', '政通人和，', '百废具兴。',
        '乃重修岳阳楼，', '增其旧制，', '刻唐贤今人诗赋于其上。', '属予作文以记之。',
        '予观夫巴陵胜状，', '在洞庭一湖。',
      ],
    ),
    Poem(
      id: 'chang_009',
      title: '出师表',
      author: '诸葛亮',
      dynasty: '三国',
      difficulty: 3,
      lines: [
        '先帝创业未半而中道崩殂，', '今天下三分，', '益州疲弊，', '此诚危急存亡之秋也。',
        '然侍卫之臣不懈于内，', '忠志之士忘身于外者，', '盖追先帝之殊遇，',
        '欲报之于陛下也。', '诚宜开张圣听，', '以光先帝遗德，', '恢弘志士之气。',
      ],
    ),
    Poem(
      id: 'chang_010',
      title: '桃花源记',
      author: '陶渊明',
      dynasty: '东晋',
      difficulty: 3,
      lines: [
        '晋太元中，', '武陵人捕鱼为业。', '缘溪行，', '忘路之远近。', '忽逢桃花林，',
        '夹岸数百步，', '中无杂树，', '芳草鲜美，', '落英缤纷。', '渔人甚异之，',
        '复前行，欲穷其林。',
      ],
    ),
  ];

  /// 按难度取全部。
  static List<Poem> byDifficulty(int difficulty) =>
      poems.where((p) => p.difficulty == difficulty).toList();

  /// 按难度随机取一首。
  static Poem randomByDifficulty(int difficulty, {int? seed}) {
    final list = byDifficulty(difficulty);
    final i = seed == null ? DateTime.now().millisecondsSinceEpoch % list.length : seed % list.length;
    return list[i];
  }

  /// 按 id 取（无则 null）。
  static Poem? byId(String id) {
    for (final p in poems) {
      if (p.id == id) return p;
    }
    return null;
  }
}
