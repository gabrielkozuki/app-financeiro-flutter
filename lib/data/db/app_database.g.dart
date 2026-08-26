// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EntradasTable extends Entradas
    with TableInfo<$EntradasTable, EntradaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntradasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorLiquidoMeta = const VerificationMeta(
    'valorLiquido',
  );
  @override
  late final GeneratedColumn<double> valorLiquido = GeneratedColumn<double>(
    'valor_liquido',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoEntrada, int> tipo =
      GeneratedColumn<int>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TipoEntrada>($EntradasTable.$convertertipo);
  static const VerificationMeta _diaRecebimentoMeta = const VerificationMeta(
    'diaRecebimento',
  );
  @override
  late final GeneratedColumn<int> diaRecebimento = GeneratedColumn<int>(
    'dia_recebimento',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  @override
  late final GeneratedColumn<String> mesReferencia = GeneratedColumn<String>(
    'mes_referencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausadaDesdeMeta = const VerificationMeta(
    'pausadaDesde',
  );
  @override
  late final GeneratedColumn<String> pausadaDesde = GeneratedColumn<String>(
    'pausada_desde',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retomadaEmMeta = const VerificationMeta(
    'retomadaEm',
  );
  @override
  late final GeneratedColumn<String> retomadaEm = GeneratedColumn<String>(
    'retomada_em',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    valorLiquido,
    tipo,
    diaRecebimento,
    mesReferencia,
    pausadaDesde,
    retomadaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entradas';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntradaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('valor_liquido')) {
      context.handle(
        _valorLiquidoMeta,
        valorLiquido.isAcceptableOrUnknown(
          data['valor_liquido']!,
          _valorLiquidoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorLiquidoMeta);
    }
    if (data.containsKey('dia_recebimento')) {
      context.handle(
        _diaRecebimentoMeta,
        diaRecebimento.isAcceptableOrUnknown(
          data['dia_recebimento']!,
          _diaRecebimentoMeta,
        ),
      );
    }
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    }
    if (data.containsKey('pausada_desde')) {
      context.handle(
        _pausadaDesdeMeta,
        pausadaDesde.isAcceptableOrUnknown(
          data['pausada_desde']!,
          _pausadaDesdeMeta,
        ),
      );
    }
    if (data.containsKey('retomada_em')) {
      context.handle(
        _retomadaEmMeta,
        retomadaEm.isAcceptableOrUnknown(data['retomada_em']!, _retomadaEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntradaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntradaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      valorLiquido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_liquido'],
      )!,
      tipo: $EntradasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      diaRecebimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_recebimento'],
      ),
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_referencia'],
      ),
      pausadaDesde: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pausada_desde'],
      ),
      retomadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retomada_em'],
      ),
    );
  }

  @override
  $EntradasTable createAlias(String alias) {
    return $EntradasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoEntrada, int, int> $convertertipo =
      const EnumIndexConverter<TipoEntrada>(TipoEntrada.values);
}

class EntradaRow extends DataClass implements Insertable<EntradaRow> {
  final int id;
  final String nome;
  final double valorLiquido;
  final TipoEntrada tipo;
  final int? diaRecebimento;
  final String? mesReferencia;

  /// Vigência da pausa, em `YYYY-MM`. Substituiu o booleano `ativa` na
  /// schemaVersion 2: pausar precisa valer **daquele mês em diante**, não
  /// retroativamente, senão pausar hoje reescreveria meses passados que ainda
  /// leem ao vivo (os reabertos).
  ///
  /// `pausadaDesde` nulo = nunca pausada. `retomadaEm` nulo = segue pausada.
  /// Retomar em outubro deixa o intervalo [pausadaDesde, outubro) sem contar e
  /// outubro em diante contando.
  final String? pausadaDesde;
  final String? retomadaEm;
  const EntradaRow({
    required this.id,
    required this.nome,
    required this.valorLiquido,
    required this.tipo,
    this.diaRecebimento,
    this.mesReferencia,
    this.pausadaDesde,
    this.retomadaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['valor_liquido'] = Variable<double>(valorLiquido);
    {
      map['tipo'] = Variable<int>($EntradasTable.$convertertipo.toSql(tipo));
    }
    if (!nullToAbsent || diaRecebimento != null) {
      map['dia_recebimento'] = Variable<int>(diaRecebimento);
    }
    if (!nullToAbsent || mesReferencia != null) {
      map['mes_referencia'] = Variable<String>(mesReferencia);
    }
    if (!nullToAbsent || pausadaDesde != null) {
      map['pausada_desde'] = Variable<String>(pausadaDesde);
    }
    if (!nullToAbsent || retomadaEm != null) {
      map['retomada_em'] = Variable<String>(retomadaEm);
    }
    return map;
  }

  EntradasCompanion toCompanion(bool nullToAbsent) {
    return EntradasCompanion(
      id: Value(id),
      nome: Value(nome),
      valorLiquido: Value(valorLiquido),
      tipo: Value(tipo),
      diaRecebimento: diaRecebimento == null && nullToAbsent
          ? const Value.absent()
          : Value(diaRecebimento),
      mesReferencia: mesReferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(mesReferencia),
      pausadaDesde: pausadaDesde == null && nullToAbsent
          ? const Value.absent()
          : Value(pausadaDesde),
      retomadaEm: retomadaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(retomadaEm),
    );
  }

  factory EntradaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntradaRow(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      valorLiquido: serializer.fromJson<double>(json['valorLiquido']),
      tipo: $EntradasTable.$convertertipo.fromJson(
        serializer.fromJson<int>(json['tipo']),
      ),
      diaRecebimento: serializer.fromJson<int?>(json['diaRecebimento']),
      mesReferencia: serializer.fromJson<String?>(json['mesReferencia']),
      pausadaDesde: serializer.fromJson<String?>(json['pausadaDesde']),
      retomadaEm: serializer.fromJson<String?>(json['retomadaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'valorLiquido': serializer.toJson<double>(valorLiquido),
      'tipo': serializer.toJson<int>(
        $EntradasTable.$convertertipo.toJson(tipo),
      ),
      'diaRecebimento': serializer.toJson<int?>(diaRecebimento),
      'mesReferencia': serializer.toJson<String?>(mesReferencia),
      'pausadaDesde': serializer.toJson<String?>(pausadaDesde),
      'retomadaEm': serializer.toJson<String?>(retomadaEm),
    };
  }

  EntradaRow copyWith({
    int? id,
    String? nome,
    double? valorLiquido,
    TipoEntrada? tipo,
    Value<int?> diaRecebimento = const Value.absent(),
    Value<String?> mesReferencia = const Value.absent(),
    Value<String?> pausadaDesde = const Value.absent(),
    Value<String?> retomadaEm = const Value.absent(),
  }) => EntradaRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    valorLiquido: valorLiquido ?? this.valorLiquido,
    tipo: tipo ?? this.tipo,
    diaRecebimento: diaRecebimento.present
        ? diaRecebimento.value
        : this.diaRecebimento,
    mesReferencia: mesReferencia.present
        ? mesReferencia.value
        : this.mesReferencia,
    pausadaDesde: pausadaDesde.present ? pausadaDesde.value : this.pausadaDesde,
    retomadaEm: retomadaEm.present ? retomadaEm.value : this.retomadaEm,
  );
  EntradaRow copyWithCompanion(EntradasCompanion data) {
    return EntradaRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      valorLiquido: data.valorLiquido.present
          ? data.valorLiquido.value
          : this.valorLiquido,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      diaRecebimento: data.diaRecebimento.present
          ? data.diaRecebimento.value
          : this.diaRecebimento,
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      pausadaDesde: data.pausadaDesde.present
          ? data.pausadaDesde.value
          : this.pausadaDesde,
      retomadaEm: data.retomadaEm.present
          ? data.retomadaEm.value
          : this.retomadaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntradaRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('valorLiquido: $valorLiquido, ')
          ..write('tipo: $tipo, ')
          ..write('diaRecebimento: $diaRecebimento, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('pausadaDesde: $pausadaDesde, ')
          ..write('retomadaEm: $retomadaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    valorLiquido,
    tipo,
    diaRecebimento,
    mesReferencia,
    pausadaDesde,
    retomadaEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntradaRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.valorLiquido == this.valorLiquido &&
          other.tipo == this.tipo &&
          other.diaRecebimento == this.diaRecebimento &&
          other.mesReferencia == this.mesReferencia &&
          other.pausadaDesde == this.pausadaDesde &&
          other.retomadaEm == this.retomadaEm);
}

class EntradasCompanion extends UpdateCompanion<EntradaRow> {
  final Value<int> id;
  final Value<String> nome;
  final Value<double> valorLiquido;
  final Value<TipoEntrada> tipo;
  final Value<int?> diaRecebimento;
  final Value<String?> mesReferencia;
  final Value<String?> pausadaDesde;
  final Value<String?> retomadaEm;
  const EntradasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.valorLiquido = const Value.absent(),
    this.tipo = const Value.absent(),
    this.diaRecebimento = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.pausadaDesde = const Value.absent(),
    this.retomadaEm = const Value.absent(),
  });
  EntradasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required double valorLiquido,
    required TipoEntrada tipo,
    this.diaRecebimento = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.pausadaDesde = const Value.absent(),
    this.retomadaEm = const Value.absent(),
  }) : nome = Value(nome),
       valorLiquido = Value(valorLiquido),
       tipo = Value(tipo);
  static Insertable<EntradaRow> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<double>? valorLiquido,
    Expression<int>? tipo,
    Expression<int>? diaRecebimento,
    Expression<String>? mesReferencia,
    Expression<String>? pausadaDesde,
    Expression<String>? retomadaEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (valorLiquido != null) 'valor_liquido': valorLiquido,
      if (tipo != null) 'tipo': tipo,
      if (diaRecebimento != null) 'dia_recebimento': diaRecebimento,
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (pausadaDesde != null) 'pausada_desde': pausadaDesde,
      if (retomadaEm != null) 'retomada_em': retomadaEm,
    });
  }

  EntradasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<double>? valorLiquido,
    Value<TipoEntrada>? tipo,
    Value<int?>? diaRecebimento,
    Value<String?>? mesReferencia,
    Value<String?>? pausadaDesde,
    Value<String?>? retomadaEm,
  }) {
    return EntradasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorLiquido: valorLiquido ?? this.valorLiquido,
      tipo: tipo ?? this.tipo,
      diaRecebimento: diaRecebimento ?? this.diaRecebimento,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      pausadaDesde: pausadaDesde ?? this.pausadaDesde,
      retomadaEm: retomadaEm ?? this.retomadaEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (valorLiquido.present) {
      map['valor_liquido'] = Variable<double>(valorLiquido.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<int>(
        $EntradasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (diaRecebimento.present) {
      map['dia_recebimento'] = Variable<int>(diaRecebimento.value);
    }
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<String>(mesReferencia.value);
    }
    if (pausadaDesde.present) {
      map['pausada_desde'] = Variable<String>(pausadaDesde.value);
    }
    if (retomadaEm.present) {
      map['retomada_em'] = Variable<String>(retomadaEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntradasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('valorLiquido: $valorLiquido, ')
          ..write('tipo: $tipo, ')
          ..write('diaRecebimento: $diaRecebimento, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('pausadaDesde: $pausadaDesde, ')
          ..write('retomadaEm: $retomadaEm')
          ..write(')'))
        .toString();
  }
}

class $ContasTable extends Contas with TableInfo<$ContasTable, ContaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Grupo, int> grupo =
      GeneratedColumn<int>(
        'grupo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Grupo>($ContasTable.$convertergrupo);
  static const VerificationMeta _valorPlanejadoMeta = const VerificationMeta(
    'valorPlanejado',
  );
  @override
  late final GeneratedColumn<double> valorPlanejado = GeneratedColumn<double>(
    'valor_planejado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Recorrencia, int> recorrencia =
      GeneratedColumn<int>(
        'recorrencia',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Recorrencia>($ContasTable.$converterrecorrencia);
  static const VerificationMeta _totalParcelasMeta = const VerificationMeta(
    'totalParcelas',
  );
  @override
  late final GeneratedColumn<int> totalParcelas = GeneratedColumn<int>(
    'total_parcelas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    grupo,
    valorPlanejado,
    diaVencimento,
    recorrencia,
    totalParcelas,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('valor_planejado')) {
      context.handle(
        _valorPlanejadoMeta,
        valorPlanejado.isAcceptableOrUnknown(
          data['valor_planejado']!,
          _valorPlanejadoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorPlanejadoMeta);
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaVencimentoMeta);
    }
    if (data.containsKey('total_parcelas')) {
      context.handle(
        _totalParcelasMeta,
        totalParcelas.isAcceptableOrUnknown(
          data['total_parcelas']!,
          _totalParcelasMeta,
        ),
      );
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      grupo: $ContasTable.$convertergrupo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}grupo'],
        )!,
      ),
      valorPlanejado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_planejado'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      recorrencia: $ContasTable.$converterrecorrencia.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}recorrencia'],
        )!,
      ),
      totalParcelas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_parcelas'],
      ),
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $ContasTable createAlias(String alias) {
    return $ContasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Grupo, int, int> $convertergrupo =
      const EnumIndexConverter<Grupo>(Grupo.values);
  static JsonTypeConverter2<Recorrencia, int, int> $converterrecorrencia =
      const EnumIndexConverter<Recorrencia>(Recorrencia.values);
}

class ContaRow extends DataClass implements Insertable<ContaRow> {
  final int id;
  final String nome;
  final Grupo grupo;
  final double valorPlanejado;
  final int diaVencimento;
  final Recorrencia recorrencia;
  final int? totalParcelas;
  final bool ativa;
  const ContaRow({
    required this.id,
    required this.nome,
    required this.grupo,
    required this.valorPlanejado,
    required this.diaVencimento,
    required this.recorrencia,
    this.totalParcelas,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    {
      map['grupo'] = Variable<int>($ContasTable.$convertergrupo.toSql(grupo));
    }
    map['valor_planejado'] = Variable<double>(valorPlanejado);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    {
      map['recorrencia'] = Variable<int>(
        $ContasTable.$converterrecorrencia.toSql(recorrencia),
      );
    }
    if (!nullToAbsent || totalParcelas != null) {
      map['total_parcelas'] = Variable<int>(totalParcelas);
    }
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  ContasCompanion toCompanion(bool nullToAbsent) {
    return ContasCompanion(
      id: Value(id),
      nome: Value(nome),
      grupo: Value(grupo),
      valorPlanejado: Value(valorPlanejado),
      diaVencimento: Value(diaVencimento),
      recorrencia: Value(recorrencia),
      totalParcelas: totalParcelas == null && nullToAbsent
          ? const Value.absent()
          : Value(totalParcelas),
      ativa: Value(ativa),
    );
  }

  factory ContaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContaRow(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      grupo: $ContasTable.$convertergrupo.fromJson(
        serializer.fromJson<int>(json['grupo']),
      ),
      valorPlanejado: serializer.fromJson<double>(json['valorPlanejado']),
      diaVencimento: serializer.fromJson<int>(json['diaVencimento']),
      recorrencia: $ContasTable.$converterrecorrencia.fromJson(
        serializer.fromJson<int>(json['recorrencia']),
      ),
      totalParcelas: serializer.fromJson<int?>(json['totalParcelas']),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'grupo': serializer.toJson<int>(
        $ContasTable.$convertergrupo.toJson(grupo),
      ),
      'valorPlanejado': serializer.toJson<double>(valorPlanejado),
      'diaVencimento': serializer.toJson<int>(diaVencimento),
      'recorrencia': serializer.toJson<int>(
        $ContasTable.$converterrecorrencia.toJson(recorrencia),
      ),
      'totalParcelas': serializer.toJson<int?>(totalParcelas),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  ContaRow copyWith({
    int? id,
    String? nome,
    Grupo? grupo,
    double? valorPlanejado,
    int? diaVencimento,
    Recorrencia? recorrencia,
    Value<int?> totalParcelas = const Value.absent(),
    bool? ativa,
  }) => ContaRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    grupo: grupo ?? this.grupo,
    valorPlanejado: valorPlanejado ?? this.valorPlanejado,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    recorrencia: recorrencia ?? this.recorrencia,
    totalParcelas: totalParcelas.present
        ? totalParcelas.value
        : this.totalParcelas,
    ativa: ativa ?? this.ativa,
  );
  ContaRow copyWithCompanion(ContasCompanion data) {
    return ContaRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      grupo: data.grupo.present ? data.grupo.value : this.grupo,
      valorPlanejado: data.valorPlanejado.present
          ? data.valorPlanejado.value
          : this.valorPlanejado,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      recorrencia: data.recorrencia.present
          ? data.recorrencia.value
          : this.recorrencia,
      totalParcelas: data.totalParcelas.present
          ? data.totalParcelas.value
          : this.totalParcelas,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContaRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('grupo: $grupo, ')
          ..write('valorPlanejado: $valorPlanejado, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('totalParcelas: $totalParcelas, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    grupo,
    valorPlanejado,
    diaVencimento,
    recorrencia,
    totalParcelas,
    ativa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContaRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.grupo == this.grupo &&
          other.valorPlanejado == this.valorPlanejado &&
          other.diaVencimento == this.diaVencimento &&
          other.recorrencia == this.recorrencia &&
          other.totalParcelas == this.totalParcelas &&
          other.ativa == this.ativa);
}

class ContasCompanion extends UpdateCompanion<ContaRow> {
  final Value<int> id;
  final Value<String> nome;
  final Value<Grupo> grupo;
  final Value<double> valorPlanejado;
  final Value<int> diaVencimento;
  final Value<Recorrencia> recorrencia;
  final Value<int?> totalParcelas;
  final Value<bool> ativa;
  const ContasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.grupo = const Value.absent(),
    this.valorPlanejado = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.recorrencia = const Value.absent(),
    this.totalParcelas = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  ContasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required Grupo grupo,
    required double valorPlanejado,
    required int diaVencimento,
    required Recorrencia recorrencia,
    this.totalParcelas = const Value.absent(),
    this.ativa = const Value.absent(),
  }) : nome = Value(nome),
       grupo = Value(grupo),
       valorPlanejado = Value(valorPlanejado),
       diaVencimento = Value(diaVencimento),
       recorrencia = Value(recorrencia);
  static Insertable<ContaRow> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? grupo,
    Expression<double>? valorPlanejado,
    Expression<int>? diaVencimento,
    Expression<int>? recorrencia,
    Expression<int>? totalParcelas,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (grupo != null) 'grupo': grupo,
      if (valorPlanejado != null) 'valor_planejado': valorPlanejado,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (recorrencia != null) 'recorrencia': recorrencia,
      if (totalParcelas != null) 'total_parcelas': totalParcelas,
      if (ativa != null) 'ativa': ativa,
    });
  }

  ContasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<Grupo>? grupo,
    Value<double>? valorPlanejado,
    Value<int>? diaVencimento,
    Value<Recorrencia>? recorrencia,
    Value<int?>? totalParcelas,
    Value<bool>? ativa,
  }) {
    return ContasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      grupo: grupo ?? this.grupo,
      valorPlanejado: valorPlanejado ?? this.valorPlanejado,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      recorrencia: recorrencia ?? this.recorrencia,
      totalParcelas: totalParcelas ?? this.totalParcelas,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (grupo.present) {
      map['grupo'] = Variable<int>(
        $ContasTable.$convertergrupo.toSql(grupo.value),
      );
    }
    if (valorPlanejado.present) {
      map['valor_planejado'] = Variable<double>(valorPlanejado.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (recorrencia.present) {
      map['recorrencia'] = Variable<int>(
        $ContasTable.$converterrecorrencia.toSql(recorrencia.value),
      );
    }
    if (totalParcelas.present) {
      map['total_parcelas'] = Variable<int>(totalParcelas.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('grupo: $grupo, ')
          ..write('valorPlanejado: $valorPlanejado, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('totalParcelas: $totalParcelas, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $OcorrenciasContaTable extends OcorrenciasConta
    with TableInfo<$OcorrenciasContaTable, OcorrenciaContaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcorrenciasContaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  @override
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contas (id)',
    ),
  );
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  @override
  late final GeneratedColumn<String> mesReferencia = GeneratedColumn<String>(
    'mes_referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorPlanejadoMeta = const VerificationMeta(
    'valorPlanejado',
  );
  @override
  late final GeneratedColumn<double> valorPlanejado = GeneratedColumn<double>(
    'valor_planejado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorPagoMeta = const VerificationMeta(
    'valorPago',
  );
  @override
  late final GeneratedColumn<double> valorPago = GeneratedColumn<double>(
    'valor_pago',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataPagamentoMeta = const VerificationMeta(
    'dataPagamento',
  );
  @override
  late final GeneratedColumn<DateTime> dataPagamento =
      GeneratedColumn<DateTime>(
        'data_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<StatusPagamento, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<StatusPagamento>($OcorrenciasContaTable.$converterstatus);
  static const VerificationMeta _parcelaAtualMeta = const VerificationMeta(
    'parcelaAtual',
  );
  @override
  late final GeneratedColumn<int> parcelaAtual = GeneratedColumn<int>(
    'parcela_atual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _removidaMeta = const VerificationMeta(
    'removida',
  );
  @override
  late final GeneratedColumn<bool> removida = GeneratedColumn<bool>(
    'removida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("removida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contaId,
    mesReferencia,
    valorPlanejado,
    valorPago,
    dataPagamento,
    status,
    parcelaAtual,
    removida,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocorrencias_conta';
  @override
  VerificationContext validateIntegrity(
    Insertable<OcorrenciaContaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contaIdMeta);
    }
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesReferenciaMeta);
    }
    if (data.containsKey('valor_planejado')) {
      context.handle(
        _valorPlanejadoMeta,
        valorPlanejado.isAcceptableOrUnknown(
          data['valor_planejado']!,
          _valorPlanejadoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorPlanejadoMeta);
    }
    if (data.containsKey('valor_pago')) {
      context.handle(
        _valorPagoMeta,
        valorPago.isAcceptableOrUnknown(data['valor_pago']!, _valorPagoMeta),
      );
    }
    if (data.containsKey('data_pagamento')) {
      context.handle(
        _dataPagamentoMeta,
        dataPagamento.isAcceptableOrUnknown(
          data['data_pagamento']!,
          _dataPagamentoMeta,
        ),
      );
    }
    if (data.containsKey('parcela_atual')) {
      context.handle(
        _parcelaAtualMeta,
        parcelaAtual.isAcceptableOrUnknown(
          data['parcela_atual']!,
          _parcelaAtualMeta,
        ),
      );
    }
    if (data.containsKey('removida')) {
      context.handle(
        _removidaMeta,
        removida.isAcceptableOrUnknown(data['removida']!, _removidaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {contaId, mesReferencia},
  ];
  @override
  OcorrenciaContaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcorrenciaContaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      )!,
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_referencia'],
      )!,
      valorPlanejado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_planejado'],
      )!,
      valorPago: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_pago'],
      ),
      dataPagamento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_pagamento'],
      ),
      status: $OcorrenciasContaTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      parcelaAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_atual'],
      ),
      removida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}removida'],
      )!,
    );
  }

  @override
  $OcorrenciasContaTable createAlias(String alias) {
    return $OcorrenciasContaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatusPagamento, int, int> $converterstatus =
      const EnumIndexConverter<StatusPagamento>(StatusPagamento.values);
}

class OcorrenciaContaRow extends DataClass
    implements Insertable<OcorrenciaContaRow> {
  final int id;
  final int contaId;
  final String mesReferencia;
  final double valorPlanejado;
  final double? valorPago;
  final DateTime? dataPagamento;
  final StatusPagamento status;
  final int? parcelaAtual;

  /// Ocorrência "removida só deste mês" (RF-07): fica oculta na checklist, mas
  /// permanece gravada para que a virada não a recrie.
  final bool removida;
  const OcorrenciaContaRow({
    required this.id,
    required this.contaId,
    required this.mesReferencia,
    required this.valorPlanejado,
    this.valorPago,
    this.dataPagamento,
    required this.status,
    this.parcelaAtual,
    required this.removida,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conta_id'] = Variable<int>(contaId);
    map['mes_referencia'] = Variable<String>(mesReferencia);
    map['valor_planejado'] = Variable<double>(valorPlanejado);
    if (!nullToAbsent || valorPago != null) {
      map['valor_pago'] = Variable<double>(valorPago);
    }
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento);
    }
    {
      map['status'] = Variable<int>(
        $OcorrenciasContaTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || parcelaAtual != null) {
      map['parcela_atual'] = Variable<int>(parcelaAtual);
    }
    map['removida'] = Variable<bool>(removida);
    return map;
  }

  OcorrenciasContaCompanion toCompanion(bool nullToAbsent) {
    return OcorrenciasContaCompanion(
      id: Value(id),
      contaId: Value(contaId),
      mesReferencia: Value(mesReferencia),
      valorPlanejado: Value(valorPlanejado),
      valorPago: valorPago == null && nullToAbsent
          ? const Value.absent()
          : Value(valorPago),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
      status: Value(status),
      parcelaAtual: parcelaAtual == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelaAtual),
      removida: Value(removida),
    );
  }

  factory OcorrenciaContaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcorrenciaContaRow(
      id: serializer.fromJson<int>(json['id']),
      contaId: serializer.fromJson<int>(json['contaId']),
      mesReferencia: serializer.fromJson<String>(json['mesReferencia']),
      valorPlanejado: serializer.fromJson<double>(json['valorPlanejado']),
      valorPago: serializer.fromJson<double?>(json['valorPago']),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
      status: $OcorrenciasContaTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      parcelaAtual: serializer.fromJson<int?>(json['parcelaAtual']),
      removida: serializer.fromJson<bool>(json['removida']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contaId': serializer.toJson<int>(contaId),
      'mesReferencia': serializer.toJson<String>(mesReferencia),
      'valorPlanejado': serializer.toJson<double>(valorPlanejado),
      'valorPago': serializer.toJson<double?>(valorPago),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
      'status': serializer.toJson<int>(
        $OcorrenciasContaTable.$converterstatus.toJson(status),
      ),
      'parcelaAtual': serializer.toJson<int?>(parcelaAtual),
      'removida': serializer.toJson<bool>(removida),
    };
  }

  OcorrenciaContaRow copyWith({
    int? id,
    int? contaId,
    String? mesReferencia,
    double? valorPlanejado,
    Value<double?> valorPago = const Value.absent(),
    Value<DateTime?> dataPagamento = const Value.absent(),
    StatusPagamento? status,
    Value<int?> parcelaAtual = const Value.absent(),
    bool? removida,
  }) => OcorrenciaContaRow(
    id: id ?? this.id,
    contaId: contaId ?? this.contaId,
    mesReferencia: mesReferencia ?? this.mesReferencia,
    valorPlanejado: valorPlanejado ?? this.valorPlanejado,
    valorPago: valorPago.present ? valorPago.value : this.valorPago,
    dataPagamento: dataPagamento.present
        ? dataPagamento.value
        : this.dataPagamento,
    status: status ?? this.status,
    parcelaAtual: parcelaAtual.present ? parcelaAtual.value : this.parcelaAtual,
    removida: removida ?? this.removida,
  );
  OcorrenciaContaRow copyWithCompanion(OcorrenciasContaCompanion data) {
    return OcorrenciaContaRow(
      id: data.id.present ? data.id.value : this.id,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      valorPlanejado: data.valorPlanejado.present
          ? data.valorPlanejado.value
          : this.valorPlanejado,
      valorPago: data.valorPago.present ? data.valorPago.value : this.valorPago,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
      status: data.status.present ? data.status.value : this.status,
      parcelaAtual: data.parcelaAtual.present
          ? data.parcelaAtual.value
          : this.parcelaAtual,
      removida: data.removida.present ? data.removida.value : this.removida,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciaContaRow(')
          ..write('id: $id, ')
          ..write('contaId: $contaId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('valorPlanejado: $valorPlanejado, ')
          ..write('valorPago: $valorPago, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status, ')
          ..write('parcelaAtual: $parcelaAtual, ')
          ..write('removida: $removida')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contaId,
    mesReferencia,
    valorPlanejado,
    valorPago,
    dataPagamento,
    status,
    parcelaAtual,
    removida,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcorrenciaContaRow &&
          other.id == this.id &&
          other.contaId == this.contaId &&
          other.mesReferencia == this.mesReferencia &&
          other.valorPlanejado == this.valorPlanejado &&
          other.valorPago == this.valorPago &&
          other.dataPagamento == this.dataPagamento &&
          other.status == this.status &&
          other.parcelaAtual == this.parcelaAtual &&
          other.removida == this.removida);
}

class OcorrenciasContaCompanion extends UpdateCompanion<OcorrenciaContaRow> {
  final Value<int> id;
  final Value<int> contaId;
  final Value<String> mesReferencia;
  final Value<double> valorPlanejado;
  final Value<double?> valorPago;
  final Value<DateTime?> dataPagamento;
  final Value<StatusPagamento> status;
  final Value<int?> parcelaAtual;
  final Value<bool> removida;
  const OcorrenciasContaCompanion({
    this.id = const Value.absent(),
    this.contaId = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.valorPlanejado = const Value.absent(),
    this.valorPago = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.status = const Value.absent(),
    this.parcelaAtual = const Value.absent(),
    this.removida = const Value.absent(),
  });
  OcorrenciasContaCompanion.insert({
    this.id = const Value.absent(),
    required int contaId,
    required String mesReferencia,
    required double valorPlanejado,
    this.valorPago = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.status = const Value.absent(),
    this.parcelaAtual = const Value.absent(),
    this.removida = const Value.absent(),
  }) : contaId = Value(contaId),
       mesReferencia = Value(mesReferencia),
       valorPlanejado = Value(valorPlanejado);
  static Insertable<OcorrenciaContaRow> custom({
    Expression<int>? id,
    Expression<int>? contaId,
    Expression<String>? mesReferencia,
    Expression<double>? valorPlanejado,
    Expression<double>? valorPago,
    Expression<DateTime>? dataPagamento,
    Expression<int>? status,
    Expression<int>? parcelaAtual,
    Expression<bool>? removida,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contaId != null) 'conta_id': contaId,
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (valorPlanejado != null) 'valor_planejado': valorPlanejado,
      if (valorPago != null) 'valor_pago': valorPago,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (status != null) 'status': status,
      if (parcelaAtual != null) 'parcela_atual': parcelaAtual,
      if (removida != null) 'removida': removida,
    });
  }

  OcorrenciasContaCompanion copyWith({
    Value<int>? id,
    Value<int>? contaId,
    Value<String>? mesReferencia,
    Value<double>? valorPlanejado,
    Value<double?>? valorPago,
    Value<DateTime?>? dataPagamento,
    Value<StatusPagamento>? status,
    Value<int?>? parcelaAtual,
    Value<bool>? removida,
  }) {
    return OcorrenciasContaCompanion(
      id: id ?? this.id,
      contaId: contaId ?? this.contaId,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      valorPlanejado: valorPlanejado ?? this.valorPlanejado,
      valorPago: valorPago ?? this.valorPago,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      removida: removida ?? this.removida,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<String>(mesReferencia.value);
    }
    if (valorPlanejado.present) {
      map['valor_planejado'] = Variable<double>(valorPlanejado.value);
    }
    if (valorPago.present) {
      map['valor_pago'] = Variable<double>(valorPago.value);
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $OcorrenciasContaTable.$converterstatus.toSql(status.value),
      );
    }
    if (parcelaAtual.present) {
      map['parcela_atual'] = Variable<int>(parcelaAtual.value);
    }
    if (removida.present) {
      map['removida'] = Variable<bool>(removida.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciasContaCompanion(')
          ..write('id: $id, ')
          ..write('contaId: $contaId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('valorPlanejado: $valorPlanejado, ')
          ..write('valorPago: $valorPago, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status, ')
          ..write('parcelaAtual: $parcelaAtual, ')
          ..write('removida: $removida')
          ..write(')'))
        .toString();
  }
}

class $CartoesTable extends Cartoes with TableInfo<$CartoesTable, CartaoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  @override
  late final GeneratedColumn<bool> ativa = GeneratedColumn<bool>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, diaVencimento, ativa];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartaoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaVencimentoMeta);
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CartaoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartaoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  $CartoesTable createAlias(String alias) {
    return $CartoesTable(attachedDatabase, alias);
  }
}

class CartaoRow extends DataClass implements Insertable<CartaoRow> {
  final int id;
  final String nome;
  final int diaVencimento;
  final bool ativa;
  const CartaoRow({
    required this.id,
    required this.nome,
    required this.diaVencimento,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    map['ativa'] = Variable<bool>(ativa);
    return map;
  }

  CartoesCompanion toCompanion(bool nullToAbsent) {
    return CartoesCompanion(
      id: Value(id),
      nome: Value(nome),
      diaVencimento: Value(diaVencimento),
      ativa: Value(ativa),
    );
  }

  factory CartaoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartaoRow(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      diaVencimento: serializer.fromJson<int>(json['diaVencimento']),
      ativa: serializer.fromJson<bool>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'diaVencimento': serializer.toJson<int>(diaVencimento),
      'ativa': serializer.toJson<bool>(ativa),
    };
  }

  CartaoRow copyWith({
    int? id,
    String? nome,
    int? diaVencimento,
    bool? ativa,
  }) => CartaoRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    ativa: ativa ?? this.ativa,
  );
  CartaoRow copyWithCompanion(CartoesCompanion data) {
    return CartaoRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartaoRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, diaVencimento, ativa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartaoRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.diaVencimento == this.diaVencimento &&
          other.ativa == this.ativa);
}

class CartoesCompanion extends UpdateCompanion<CartaoRow> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> diaVencimento;
  final Value<bool> ativa;
  const CartoesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  CartoesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int diaVencimento,
    this.ativa = const Value.absent(),
  }) : nome = Value(nome),
       diaVencimento = Value(diaVencimento);
  static Insertable<CartaoRow> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? diaVencimento,
    Expression<bool>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (ativa != null) 'ativa': ativa,
    });
  }

  CartoesCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? diaVencimento,
    Value<bool>? ativa,
  }) {
    return CartoesCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<bool>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartoesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class $FaturasCartaoTable extends FaturasCartao
    with TableInfo<$FaturasCartaoTable, FaturaCartaoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaturasCartaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cartoes (id)',
    ),
  );
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  @override
  late final GeneratedColumn<String> mesReferencia = GeneratedColumn<String>(
    'mes_referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorTotalMeta = const VerificationMeta(
    'valorTotal',
  );
  @override
  late final GeneratedColumn<double> valorTotal = GeneratedColumn<double>(
    'valor_total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorPagoMeta = const VerificationMeta(
    'valorPago',
  );
  @override
  late final GeneratedColumn<double> valorPago = GeneratedColumn<double>(
    'valor_pago',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataPagamentoMeta = const VerificationMeta(
    'dataPagamento',
  );
  @override
  late final GeneratedColumn<DateTime> dataPagamento =
      GeneratedColumn<DateTime>(
        'data_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<StatusPagamento, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<StatusPagamento>($FaturasCartaoTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartaoId,
    mesReferencia,
    valorTotal,
    valorPago,
    dataPagamento,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faturas_cartao';
  @override
  VerificationContext validateIntegrity(
    Insertable<FaturaCartaoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaoIdMeta);
    }
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesReferenciaMeta);
    }
    if (data.containsKey('valor_total')) {
      context.handle(
        _valorTotalMeta,
        valorTotal.isAcceptableOrUnknown(data['valor_total']!, _valorTotalMeta),
      );
    }
    if (data.containsKey('valor_pago')) {
      context.handle(
        _valorPagoMeta,
        valorPago.isAcceptableOrUnknown(data['valor_pago']!, _valorPagoMeta),
      );
    }
    if (data.containsKey('data_pagamento')) {
      context.handle(
        _dataPagamentoMeta,
        dataPagamento.isAcceptableOrUnknown(
          data['data_pagamento']!,
          _dataPagamentoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cartaoId, mesReferencia},
  ];
  @override
  FaturaCartaoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaturaCartaoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      )!,
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_referencia'],
      )!,
      valorTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_total'],
      ),
      valorPago: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor_pago'],
      ),
      dataPagamento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_pagamento'],
      ),
      status: $FaturasCartaoTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $FaturasCartaoTable createAlias(String alias) {
    return $FaturasCartaoTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatusPagamento, int, int> $converterstatus =
      const EnumIndexConverter<StatusPagamento>(StatusPagamento.values);
}

class FaturaCartaoRow extends DataClass implements Insertable<FaturaCartaoRow> {
  final int id;
  final int cartaoId;
  final String mesReferencia;
  final double? valorTotal;
  final double? valorPago;
  final DateTime? dataPagamento;
  final StatusPagamento status;
  const FaturaCartaoRow({
    required this.id,
    required this.cartaoId,
    required this.mesReferencia,
    this.valorTotal,
    this.valorPago,
    this.dataPagamento,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cartao_id'] = Variable<int>(cartaoId);
    map['mes_referencia'] = Variable<String>(mesReferencia);
    if (!nullToAbsent || valorTotal != null) {
      map['valor_total'] = Variable<double>(valorTotal);
    }
    if (!nullToAbsent || valorPago != null) {
      map['valor_pago'] = Variable<double>(valorPago);
    }
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento);
    }
    {
      map['status'] = Variable<int>(
        $FaturasCartaoTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  FaturasCartaoCompanion toCompanion(bool nullToAbsent) {
    return FaturasCartaoCompanion(
      id: Value(id),
      cartaoId: Value(cartaoId),
      mesReferencia: Value(mesReferencia),
      valorTotal: valorTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(valorTotal),
      valorPago: valorPago == null && nullToAbsent
          ? const Value.absent()
          : Value(valorPago),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
      status: Value(status),
    );
  }

  factory FaturaCartaoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaturaCartaoRow(
      id: serializer.fromJson<int>(json['id']),
      cartaoId: serializer.fromJson<int>(json['cartaoId']),
      mesReferencia: serializer.fromJson<String>(json['mesReferencia']),
      valorTotal: serializer.fromJson<double?>(json['valorTotal']),
      valorPago: serializer.fromJson<double?>(json['valorPago']),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
      status: $FaturasCartaoTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartaoId': serializer.toJson<int>(cartaoId),
      'mesReferencia': serializer.toJson<String>(mesReferencia),
      'valorTotal': serializer.toJson<double?>(valorTotal),
      'valorPago': serializer.toJson<double?>(valorPago),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
      'status': serializer.toJson<int>(
        $FaturasCartaoTable.$converterstatus.toJson(status),
      ),
    };
  }

  FaturaCartaoRow copyWith({
    int? id,
    int? cartaoId,
    String? mesReferencia,
    Value<double?> valorTotal = const Value.absent(),
    Value<double?> valorPago = const Value.absent(),
    Value<DateTime?> dataPagamento = const Value.absent(),
    StatusPagamento? status,
  }) => FaturaCartaoRow(
    id: id ?? this.id,
    cartaoId: cartaoId ?? this.cartaoId,
    mesReferencia: mesReferencia ?? this.mesReferencia,
    valorTotal: valorTotal.present ? valorTotal.value : this.valorTotal,
    valorPago: valorPago.present ? valorPago.value : this.valorPago,
    dataPagamento: dataPagamento.present
        ? dataPagamento.value
        : this.dataPagamento,
    status: status ?? this.status,
  );
  FaturaCartaoRow copyWithCompanion(FaturasCartaoCompanion data) {
    return FaturaCartaoRow(
      id: data.id.present ? data.id.value : this.id,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      valorTotal: data.valorTotal.present
          ? data.valorTotal.value
          : this.valorTotal,
      valorPago: data.valorPago.present ? data.valorPago.value : this.valorPago,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaturaCartaoRow(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('valorPago: $valorPago, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cartaoId,
    mesReferencia,
    valorTotal,
    valorPago,
    dataPagamento,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaturaCartaoRow &&
          other.id == this.id &&
          other.cartaoId == this.cartaoId &&
          other.mesReferencia == this.mesReferencia &&
          other.valorTotal == this.valorTotal &&
          other.valorPago == this.valorPago &&
          other.dataPagamento == this.dataPagamento &&
          other.status == this.status);
}

class FaturasCartaoCompanion extends UpdateCompanion<FaturaCartaoRow> {
  final Value<int> id;
  final Value<int> cartaoId;
  final Value<String> mesReferencia;
  final Value<double?> valorTotal;
  final Value<double?> valorPago;
  final Value<DateTime?> dataPagamento;
  final Value<StatusPagamento> status;
  const FaturasCartaoCompanion({
    this.id = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.valorTotal = const Value.absent(),
    this.valorPago = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.status = const Value.absent(),
  });
  FaturasCartaoCompanion.insert({
    this.id = const Value.absent(),
    required int cartaoId,
    required String mesReferencia,
    this.valorTotal = const Value.absent(),
    this.valorPago = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.status = const Value.absent(),
  }) : cartaoId = Value(cartaoId),
       mesReferencia = Value(mesReferencia);
  static Insertable<FaturaCartaoRow> custom({
    Expression<int>? id,
    Expression<int>? cartaoId,
    Expression<String>? mesReferencia,
    Expression<double>? valorTotal,
    Expression<double>? valorPago,
    Expression<DateTime>? dataPagamento,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (valorTotal != null) 'valor_total': valorTotal,
      if (valorPago != null) 'valor_pago': valorPago,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (status != null) 'status': status,
    });
  }

  FaturasCartaoCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaoId,
    Value<String>? mesReferencia,
    Value<double?>? valorTotal,
    Value<double?>? valorPago,
    Value<DateTime?>? dataPagamento,
    Value<StatusPagamento>? status,
  }) {
    return FaturasCartaoCompanion(
      id: id ?? this.id,
      cartaoId: cartaoId ?? this.cartaoId,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      valorTotal: valorTotal ?? this.valorTotal,
      valorPago: valorPago ?? this.valorPago,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<String>(mesReferencia.value);
    }
    if (valorTotal.present) {
      map['valor_total'] = Variable<double>(valorTotal.value);
    }
    if (valorPago.present) {
      map['valor_pago'] = Variable<double>(valorPago.value);
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $FaturasCartaoTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaturasCartaoCompanion(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('valorTotal: $valorTotal, ')
          ..write('valorPago: $valorPago, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RateiosFaturaTable extends RateiosFatura
    with TableInfo<$RateiosFaturaTable, RateioFaturaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateiosFaturaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _faturaCartaoIdMeta = const VerificationMeta(
    'faturaCartaoId',
  );
  @override
  late final GeneratedColumn<int> faturaCartaoId = GeneratedColumn<int>(
    'fatura_cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES faturas_cartao (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Grupo, int> grupo =
      GeneratedColumn<int>(
        'grupo',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Grupo>($RateiosFaturaTable.$convertergrupo);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, faturaCartaoId, grupo, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rateios_fatura';
  @override
  VerificationContext validateIntegrity(
    Insertable<RateioFaturaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fatura_cartao_id')) {
      context.handle(
        _faturaCartaoIdMeta,
        faturaCartaoId.isAcceptableOrUnknown(
          data['fatura_cartao_id']!,
          _faturaCartaoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_faturaCartaoIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RateioFaturaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateioFaturaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      faturaCartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatura_cartao_id'],
      )!,
      grupo: $RateiosFaturaTable.$convertergrupo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}grupo'],
        )!,
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $RateiosFaturaTable createAlias(String alias) {
    return $RateiosFaturaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Grupo, int, int> $convertergrupo =
      const EnumIndexConverter<Grupo>(Grupo.values);
}

class RateioFaturaRow extends DataClass implements Insertable<RateioFaturaRow> {
  final int id;
  final int faturaCartaoId;
  final Grupo grupo;
  final double valor;
  const RateioFaturaRow({
    required this.id,
    required this.faturaCartaoId,
    required this.grupo,
    required this.valor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fatura_cartao_id'] = Variable<int>(faturaCartaoId);
    {
      map['grupo'] = Variable<int>(
        $RateiosFaturaTable.$convertergrupo.toSql(grupo),
      );
    }
    map['valor'] = Variable<double>(valor);
    return map;
  }

  RateiosFaturaCompanion toCompanion(bool nullToAbsent) {
    return RateiosFaturaCompanion(
      id: Value(id),
      faturaCartaoId: Value(faturaCartaoId),
      grupo: Value(grupo),
      valor: Value(valor),
    );
  }

  factory RateioFaturaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateioFaturaRow(
      id: serializer.fromJson<int>(json['id']),
      faturaCartaoId: serializer.fromJson<int>(json['faturaCartaoId']),
      grupo: $RateiosFaturaTable.$convertergrupo.fromJson(
        serializer.fromJson<int>(json['grupo']),
      ),
      valor: serializer.fromJson<double>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'faturaCartaoId': serializer.toJson<int>(faturaCartaoId),
      'grupo': serializer.toJson<int>(
        $RateiosFaturaTable.$convertergrupo.toJson(grupo),
      ),
      'valor': serializer.toJson<double>(valor),
    };
  }

  RateioFaturaRow copyWith({
    int? id,
    int? faturaCartaoId,
    Grupo? grupo,
    double? valor,
  }) => RateioFaturaRow(
    id: id ?? this.id,
    faturaCartaoId: faturaCartaoId ?? this.faturaCartaoId,
    grupo: grupo ?? this.grupo,
    valor: valor ?? this.valor,
  );
  RateioFaturaRow copyWithCompanion(RateiosFaturaCompanion data) {
    return RateioFaturaRow(
      id: data.id.present ? data.id.value : this.id,
      faturaCartaoId: data.faturaCartaoId.present
          ? data.faturaCartaoId.value
          : this.faturaCartaoId,
      grupo: data.grupo.present ? data.grupo.value : this.grupo,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateioFaturaRow(')
          ..write('id: $id, ')
          ..write('faturaCartaoId: $faturaCartaoId, ')
          ..write('grupo: $grupo, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, faturaCartaoId, grupo, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateioFaturaRow &&
          other.id == this.id &&
          other.faturaCartaoId == this.faturaCartaoId &&
          other.grupo == this.grupo &&
          other.valor == this.valor);
}

class RateiosFaturaCompanion extends UpdateCompanion<RateioFaturaRow> {
  final Value<int> id;
  final Value<int> faturaCartaoId;
  final Value<Grupo> grupo;
  final Value<double> valor;
  const RateiosFaturaCompanion({
    this.id = const Value.absent(),
    this.faturaCartaoId = const Value.absent(),
    this.grupo = const Value.absent(),
    this.valor = const Value.absent(),
  });
  RateiosFaturaCompanion.insert({
    this.id = const Value.absent(),
    required int faturaCartaoId,
    required Grupo grupo,
    required double valor,
  }) : faturaCartaoId = Value(faturaCartaoId),
       grupo = Value(grupo),
       valor = Value(valor);
  static Insertable<RateioFaturaRow> custom({
    Expression<int>? id,
    Expression<int>? faturaCartaoId,
    Expression<int>? grupo,
    Expression<double>? valor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (faturaCartaoId != null) 'fatura_cartao_id': faturaCartaoId,
      if (grupo != null) 'grupo': grupo,
      if (valor != null) 'valor': valor,
    });
  }

  RateiosFaturaCompanion copyWith({
    Value<int>? id,
    Value<int>? faturaCartaoId,
    Value<Grupo>? grupo,
    Value<double>? valor,
  }) {
    return RateiosFaturaCompanion(
      id: id ?? this.id,
      faturaCartaoId: faturaCartaoId ?? this.faturaCartaoId,
      grupo: grupo ?? this.grupo,
      valor: valor ?? this.valor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (faturaCartaoId.present) {
      map['fatura_cartao_id'] = Variable<int>(faturaCartaoId.value);
    }
    if (grupo.present) {
      map['grupo'] = Variable<int>(
        $RateiosFaturaTable.$convertergrupo.toSql(grupo.value),
      );
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateiosFaturaCompanion(')
          ..write('id: $id, ')
          ..write('faturaCartaoId: $faturaCartaoId, ')
          ..write('grupo: $grupo, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracoesMetodologiaTable extends ConfiguracoesMetodologia
    with TableInfo<$ConfiguracoesMetodologiaTable, ConfiguracaoMetodologiaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracoesMetodologiaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mesVigenciaInicialMeta =
      const VerificationMeta('mesVigenciaInicial');
  @override
  late final GeneratedColumn<String> mesVigenciaInicial =
      GeneratedColumn<String>(
        'mes_vigencia_inicial',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _percentualNecessidadesMeta =
      const VerificationMeta('percentualNecessidades');
  @override
  late final GeneratedColumn<double> percentualNecessidades =
      GeneratedColumn<double>(
        'percentual_necessidades',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(50),
      );
  static const VerificationMeta _percentualDesejosMeta = const VerificationMeta(
    'percentualDesejos',
  );
  @override
  late final GeneratedColumn<double> percentualDesejos =
      GeneratedColumn<double>(
        'percentual_desejos',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(30),
      );
  static const VerificationMeta _percentualPoupancaMeta =
      const VerificationMeta('percentualPoupanca');
  @override
  late final GeneratedColumn<double> percentualPoupanca =
      GeneratedColumn<double>(
        'percentual_poupanca',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(20),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mesVigenciaInicial,
    percentualNecessidades,
    percentualDesejos,
    percentualPoupanca,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracoes_metodologia';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfiguracaoMetodologiaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mes_vigencia_inicial')) {
      context.handle(
        _mesVigenciaInicialMeta,
        mesVigenciaInicial.isAcceptableOrUnknown(
          data['mes_vigencia_inicial']!,
          _mesVigenciaInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesVigenciaInicialMeta);
    }
    if (data.containsKey('percentual_necessidades')) {
      context.handle(
        _percentualNecessidadesMeta,
        percentualNecessidades.isAcceptableOrUnknown(
          data['percentual_necessidades']!,
          _percentualNecessidadesMeta,
        ),
      );
    }
    if (data.containsKey('percentual_desejos')) {
      context.handle(
        _percentualDesejosMeta,
        percentualDesejos.isAcceptableOrUnknown(
          data['percentual_desejos']!,
          _percentualDesejosMeta,
        ),
      );
    }
    if (data.containsKey('percentual_poupanca')) {
      context.handle(
        _percentualPoupancaMeta,
        percentualPoupanca.isAcceptableOrUnknown(
          data['percentual_poupanca']!,
          _percentualPoupancaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfiguracaoMetodologiaRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracaoMetodologiaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mesVigenciaInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_vigencia_inicial'],
      )!,
      percentualNecessidades: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentual_necessidades'],
      )!,
      percentualDesejos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentual_desejos'],
      )!,
      percentualPoupanca: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentual_poupanca'],
      )!,
    );
  }

  @override
  $ConfiguracoesMetodologiaTable createAlias(String alias) {
    return $ConfiguracoesMetodologiaTable(attachedDatabase, alias);
  }
}

class ConfiguracaoMetodologiaRow extends DataClass
    implements Insertable<ConfiguracaoMetodologiaRow> {
  final int id;
  final String mesVigenciaInicial;
  final double percentualNecessidades;
  final double percentualDesejos;
  final double percentualPoupanca;
  const ConfiguracaoMetodologiaRow({
    required this.id,
    required this.mesVigenciaInicial,
    required this.percentualNecessidades,
    required this.percentualDesejos,
    required this.percentualPoupanca,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mes_vigencia_inicial'] = Variable<String>(mesVigenciaInicial);
    map['percentual_necessidades'] = Variable<double>(percentualNecessidades);
    map['percentual_desejos'] = Variable<double>(percentualDesejos);
    map['percentual_poupanca'] = Variable<double>(percentualPoupanca);
    return map;
  }

  ConfiguracoesMetodologiaCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracoesMetodologiaCompanion(
      id: Value(id),
      mesVigenciaInicial: Value(mesVigenciaInicial),
      percentualNecessidades: Value(percentualNecessidades),
      percentualDesejos: Value(percentualDesejos),
      percentualPoupanca: Value(percentualPoupanca),
    );
  }

  factory ConfiguracaoMetodologiaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracaoMetodologiaRow(
      id: serializer.fromJson<int>(json['id']),
      mesVigenciaInicial: serializer.fromJson<String>(
        json['mesVigenciaInicial'],
      ),
      percentualNecessidades: serializer.fromJson<double>(
        json['percentualNecessidades'],
      ),
      percentualDesejos: serializer.fromJson<double>(json['percentualDesejos']),
      percentualPoupanca: serializer.fromJson<double>(
        json['percentualPoupanca'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mesVigenciaInicial': serializer.toJson<String>(mesVigenciaInicial),
      'percentualNecessidades': serializer.toJson<double>(
        percentualNecessidades,
      ),
      'percentualDesejos': serializer.toJson<double>(percentualDesejos),
      'percentualPoupanca': serializer.toJson<double>(percentualPoupanca),
    };
  }

  ConfiguracaoMetodologiaRow copyWith({
    int? id,
    String? mesVigenciaInicial,
    double? percentualNecessidades,
    double? percentualDesejos,
    double? percentualPoupanca,
  }) => ConfiguracaoMetodologiaRow(
    id: id ?? this.id,
    mesVigenciaInicial: mesVigenciaInicial ?? this.mesVigenciaInicial,
    percentualNecessidades:
        percentualNecessidades ?? this.percentualNecessidades,
    percentualDesejos: percentualDesejos ?? this.percentualDesejos,
    percentualPoupanca: percentualPoupanca ?? this.percentualPoupanca,
  );
  ConfiguracaoMetodologiaRow copyWithCompanion(
    ConfiguracoesMetodologiaCompanion data,
  ) {
    return ConfiguracaoMetodologiaRow(
      id: data.id.present ? data.id.value : this.id,
      mesVigenciaInicial: data.mesVigenciaInicial.present
          ? data.mesVigenciaInicial.value
          : this.mesVigenciaInicial,
      percentualNecessidades: data.percentualNecessidades.present
          ? data.percentualNecessidades.value
          : this.percentualNecessidades,
      percentualDesejos: data.percentualDesejos.present
          ? data.percentualDesejos.value
          : this.percentualDesejos,
      percentualPoupanca: data.percentualPoupanca.present
          ? data.percentualPoupanca.value
          : this.percentualPoupanca,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracaoMetodologiaRow(')
          ..write('id: $id, ')
          ..write('mesVigenciaInicial: $mesVigenciaInicial, ')
          ..write('percentualNecessidades: $percentualNecessidades, ')
          ..write('percentualDesejos: $percentualDesejos, ')
          ..write('percentualPoupanca: $percentualPoupanca')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mesVigenciaInicial,
    percentualNecessidades,
    percentualDesejos,
    percentualPoupanca,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracaoMetodologiaRow &&
          other.id == this.id &&
          other.mesVigenciaInicial == this.mesVigenciaInicial &&
          other.percentualNecessidades == this.percentualNecessidades &&
          other.percentualDesejos == this.percentualDesejos &&
          other.percentualPoupanca == this.percentualPoupanca);
}

class ConfiguracoesMetodologiaCompanion
    extends UpdateCompanion<ConfiguracaoMetodologiaRow> {
  final Value<int> id;
  final Value<String> mesVigenciaInicial;
  final Value<double> percentualNecessidades;
  final Value<double> percentualDesejos;
  final Value<double> percentualPoupanca;
  const ConfiguracoesMetodologiaCompanion({
    this.id = const Value.absent(),
    this.mesVigenciaInicial = const Value.absent(),
    this.percentualNecessidades = const Value.absent(),
    this.percentualDesejos = const Value.absent(),
    this.percentualPoupanca = const Value.absent(),
  });
  ConfiguracoesMetodologiaCompanion.insert({
    this.id = const Value.absent(),
    required String mesVigenciaInicial,
    this.percentualNecessidades = const Value.absent(),
    this.percentualDesejos = const Value.absent(),
    this.percentualPoupanca = const Value.absent(),
  }) : mesVigenciaInicial = Value(mesVigenciaInicial);
  static Insertable<ConfiguracaoMetodologiaRow> custom({
    Expression<int>? id,
    Expression<String>? mesVigenciaInicial,
    Expression<double>? percentualNecessidades,
    Expression<double>? percentualDesejos,
    Expression<double>? percentualPoupanca,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mesVigenciaInicial != null)
        'mes_vigencia_inicial': mesVigenciaInicial,
      if (percentualNecessidades != null)
        'percentual_necessidades': percentualNecessidades,
      if (percentualDesejos != null) 'percentual_desejos': percentualDesejos,
      if (percentualPoupanca != null) 'percentual_poupanca': percentualPoupanca,
    });
  }

  ConfiguracoesMetodologiaCompanion copyWith({
    Value<int>? id,
    Value<String>? mesVigenciaInicial,
    Value<double>? percentualNecessidades,
    Value<double>? percentualDesejos,
    Value<double>? percentualPoupanca,
  }) {
    return ConfiguracoesMetodologiaCompanion(
      id: id ?? this.id,
      mesVigenciaInicial: mesVigenciaInicial ?? this.mesVigenciaInicial,
      percentualNecessidades:
          percentualNecessidades ?? this.percentualNecessidades,
      percentualDesejos: percentualDesejos ?? this.percentualDesejos,
      percentualPoupanca: percentualPoupanca ?? this.percentualPoupanca,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mesVigenciaInicial.present) {
      map['mes_vigencia_inicial'] = Variable<String>(mesVigenciaInicial.value);
    }
    if (percentualNecessidades.present) {
      map['percentual_necessidades'] = Variable<double>(
        percentualNecessidades.value,
      );
    }
    if (percentualDesejos.present) {
      map['percentual_desejos'] = Variable<double>(percentualDesejos.value);
    }
    if (percentualPoupanca.present) {
      map['percentual_poupanca'] = Variable<double>(percentualPoupanca.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracoesMetodologiaCompanion(')
          ..write('id: $id, ')
          ..write('mesVigenciaInicial: $mesVigenciaInicial, ')
          ..write('percentualNecessidades: $percentualNecessidades, ')
          ..write('percentualDesejos: $percentualDesejos, ')
          ..write('percentualPoupanca: $percentualPoupanca')
          ..write(')'))
        .toString();
  }
}

class $FechamentosMensaisTable extends FechamentosMensais
    with TableInfo<$FechamentosMensaisTable, FechamentoMensalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FechamentosMensaisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  @override
  late final GeneratedColumn<String> mesReferencia = GeneratedColumn<String>(
    'mes_referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rendaTotalMeta = const VerificationMeta(
    'rendaTotal',
  );
  @override
  late final GeneratedColumn<double> rendaTotal = GeneratedColumn<double>(
    'renda_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalNecessidadeMeta = const VerificationMeta(
    'totalNecessidade',
  );
  @override
  late final GeneratedColumn<double> totalNecessidade = GeneratedColumn<double>(
    'total_necessidade',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDesejoMeta = const VerificationMeta(
    'totalDesejo',
  );
  @override
  late final GeneratedColumn<double> totalDesejo = GeneratedColumn<double>(
    'total_desejo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalInvestimentoMeta = const VerificationMeta(
    'totalInvestimento',
  );
  @override
  late final GeneratedColumn<double> totalInvestimento =
      GeneratedColumn<double>(
        'total_investimento',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _snapNecessidadesMeta = const VerificationMeta(
    'snapNecessidades',
  );
  @override
  late final GeneratedColumn<double> snapNecessidades = GeneratedColumn<double>(
    'snap_necessidades',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _snapDesejosMeta = const VerificationMeta(
    'snapDesejos',
  );
  @override
  late final GeneratedColumn<double> snapDesejos = GeneratedColumn<double>(
    'snap_desejos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _snapPoupancaMeta = const VerificationMeta(
    'snapPoupanca',
  );
  @override
  late final GeneratedColumn<double> snapPoupanca = GeneratedColumn<double>(
    'snap_poupanca',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  @override
  List<GeneratedColumn> get $columns => [
    mesReferencia,
    rendaTotal,
    totalNecessidade,
    totalDesejo,
    totalInvestimento,
    snapNecessidades,
    snapDesejos,
    snapPoupanca,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fechamentos_mensais';
  @override
  VerificationContext validateIntegrity(
    Insertable<FechamentoMensalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesReferenciaMeta);
    }
    if (data.containsKey('renda_total')) {
      context.handle(
        _rendaTotalMeta,
        rendaTotal.isAcceptableOrUnknown(data['renda_total']!, _rendaTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_rendaTotalMeta);
    }
    if (data.containsKey('total_necessidade')) {
      context.handle(
        _totalNecessidadeMeta,
        totalNecessidade.isAcceptableOrUnknown(
          data['total_necessidade']!,
          _totalNecessidadeMeta,
        ),
      );
    }
    if (data.containsKey('total_desejo')) {
      context.handle(
        _totalDesejoMeta,
        totalDesejo.isAcceptableOrUnknown(
          data['total_desejo']!,
          _totalDesejoMeta,
        ),
      );
    }
    if (data.containsKey('total_investimento')) {
      context.handle(
        _totalInvestimentoMeta,
        totalInvestimento.isAcceptableOrUnknown(
          data['total_investimento']!,
          _totalInvestimentoMeta,
        ),
      );
    }
    if (data.containsKey('snap_necessidades')) {
      context.handle(
        _snapNecessidadesMeta,
        snapNecessidades.isAcceptableOrUnknown(
          data['snap_necessidades']!,
          _snapNecessidadesMeta,
        ),
      );
    }
    if (data.containsKey('snap_desejos')) {
      context.handle(
        _snapDesejosMeta,
        snapDesejos.isAcceptableOrUnknown(
          data['snap_desejos']!,
          _snapDesejosMeta,
        ),
      );
    }
    if (data.containsKey('snap_poupanca')) {
      context.handle(
        _snapPoupancaMeta,
        snapPoupanca.isAcceptableOrUnknown(
          data['snap_poupanca']!,
          _snapPoupancaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mesReferencia};
  @override
  FechamentoMensalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FechamentoMensalRow(
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_referencia'],
      )!,
      rendaTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}renda_total'],
      )!,
      totalNecessidade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_necessidade'],
      )!,
      totalDesejo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_desejo'],
      )!,
      totalInvestimento: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_investimento'],
      )!,
      snapNecessidades: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}snap_necessidades'],
      )!,
      snapDesejos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}snap_desejos'],
      )!,
      snapPoupanca: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}snap_poupanca'],
      )!,
    );
  }

  @override
  $FechamentosMensaisTable createAlias(String alias) {
    return $FechamentosMensaisTable(attachedDatabase, alias);
  }
}

class FechamentoMensalRow extends DataClass
    implements Insertable<FechamentoMensalRow> {
  final String mesReferencia;
  final double rendaTotal;
  final double totalNecessidade;
  final double totalDesejo;
  final double totalInvestimento;
  final double snapNecessidades;
  final double snapDesejos;
  final double snapPoupanca;
  const FechamentoMensalRow({
    required this.mesReferencia,
    required this.rendaTotal,
    required this.totalNecessidade,
    required this.totalDesejo,
    required this.totalInvestimento,
    required this.snapNecessidades,
    required this.snapDesejos,
    required this.snapPoupanca,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mes_referencia'] = Variable<String>(mesReferencia);
    map['renda_total'] = Variable<double>(rendaTotal);
    map['total_necessidade'] = Variable<double>(totalNecessidade);
    map['total_desejo'] = Variable<double>(totalDesejo);
    map['total_investimento'] = Variable<double>(totalInvestimento);
    map['snap_necessidades'] = Variable<double>(snapNecessidades);
    map['snap_desejos'] = Variable<double>(snapDesejos);
    map['snap_poupanca'] = Variable<double>(snapPoupanca);
    return map;
  }

  FechamentosMensaisCompanion toCompanion(bool nullToAbsent) {
    return FechamentosMensaisCompanion(
      mesReferencia: Value(mesReferencia),
      rendaTotal: Value(rendaTotal),
      totalNecessidade: Value(totalNecessidade),
      totalDesejo: Value(totalDesejo),
      totalInvestimento: Value(totalInvestimento),
      snapNecessidades: Value(snapNecessidades),
      snapDesejos: Value(snapDesejos),
      snapPoupanca: Value(snapPoupanca),
    );
  }

  factory FechamentoMensalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FechamentoMensalRow(
      mesReferencia: serializer.fromJson<String>(json['mesReferencia']),
      rendaTotal: serializer.fromJson<double>(json['rendaTotal']),
      totalNecessidade: serializer.fromJson<double>(json['totalNecessidade']),
      totalDesejo: serializer.fromJson<double>(json['totalDesejo']),
      totalInvestimento: serializer.fromJson<double>(json['totalInvestimento']),
      snapNecessidades: serializer.fromJson<double>(json['snapNecessidades']),
      snapDesejos: serializer.fromJson<double>(json['snapDesejos']),
      snapPoupanca: serializer.fromJson<double>(json['snapPoupanca']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mesReferencia': serializer.toJson<String>(mesReferencia),
      'rendaTotal': serializer.toJson<double>(rendaTotal),
      'totalNecessidade': serializer.toJson<double>(totalNecessidade),
      'totalDesejo': serializer.toJson<double>(totalDesejo),
      'totalInvestimento': serializer.toJson<double>(totalInvestimento),
      'snapNecessidades': serializer.toJson<double>(snapNecessidades),
      'snapDesejos': serializer.toJson<double>(snapDesejos),
      'snapPoupanca': serializer.toJson<double>(snapPoupanca),
    };
  }

  FechamentoMensalRow copyWith({
    String? mesReferencia,
    double? rendaTotal,
    double? totalNecessidade,
    double? totalDesejo,
    double? totalInvestimento,
    double? snapNecessidades,
    double? snapDesejos,
    double? snapPoupanca,
  }) => FechamentoMensalRow(
    mesReferencia: mesReferencia ?? this.mesReferencia,
    rendaTotal: rendaTotal ?? this.rendaTotal,
    totalNecessidade: totalNecessidade ?? this.totalNecessidade,
    totalDesejo: totalDesejo ?? this.totalDesejo,
    totalInvestimento: totalInvestimento ?? this.totalInvestimento,
    snapNecessidades: snapNecessidades ?? this.snapNecessidades,
    snapDesejos: snapDesejos ?? this.snapDesejos,
    snapPoupanca: snapPoupanca ?? this.snapPoupanca,
  );
  FechamentoMensalRow copyWithCompanion(FechamentosMensaisCompanion data) {
    return FechamentoMensalRow(
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      rendaTotal: data.rendaTotal.present
          ? data.rendaTotal.value
          : this.rendaTotal,
      totalNecessidade: data.totalNecessidade.present
          ? data.totalNecessidade.value
          : this.totalNecessidade,
      totalDesejo: data.totalDesejo.present
          ? data.totalDesejo.value
          : this.totalDesejo,
      totalInvestimento: data.totalInvestimento.present
          ? data.totalInvestimento.value
          : this.totalInvestimento,
      snapNecessidades: data.snapNecessidades.present
          ? data.snapNecessidades.value
          : this.snapNecessidades,
      snapDesejos: data.snapDesejos.present
          ? data.snapDesejos.value
          : this.snapDesejos,
      snapPoupanca: data.snapPoupanca.present
          ? data.snapPoupanca.value
          : this.snapPoupanca,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FechamentoMensalRow(')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('rendaTotal: $rendaTotal, ')
          ..write('totalNecessidade: $totalNecessidade, ')
          ..write('totalDesejo: $totalDesejo, ')
          ..write('totalInvestimento: $totalInvestimento, ')
          ..write('snapNecessidades: $snapNecessidades, ')
          ..write('snapDesejos: $snapDesejos, ')
          ..write('snapPoupanca: $snapPoupanca')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mesReferencia,
    rendaTotal,
    totalNecessidade,
    totalDesejo,
    totalInvestimento,
    snapNecessidades,
    snapDesejos,
    snapPoupanca,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FechamentoMensalRow &&
          other.mesReferencia == this.mesReferencia &&
          other.rendaTotal == this.rendaTotal &&
          other.totalNecessidade == this.totalNecessidade &&
          other.totalDesejo == this.totalDesejo &&
          other.totalInvestimento == this.totalInvestimento &&
          other.snapNecessidades == this.snapNecessidades &&
          other.snapDesejos == this.snapDesejos &&
          other.snapPoupanca == this.snapPoupanca);
}

class FechamentosMensaisCompanion extends UpdateCompanion<FechamentoMensalRow> {
  final Value<String> mesReferencia;
  final Value<double> rendaTotal;
  final Value<double> totalNecessidade;
  final Value<double> totalDesejo;
  final Value<double> totalInvestimento;
  final Value<double> snapNecessidades;
  final Value<double> snapDesejos;
  final Value<double> snapPoupanca;
  final Value<int> rowid;
  const FechamentosMensaisCompanion({
    this.mesReferencia = const Value.absent(),
    this.rendaTotal = const Value.absent(),
    this.totalNecessidade = const Value.absent(),
    this.totalDesejo = const Value.absent(),
    this.totalInvestimento = const Value.absent(),
    this.snapNecessidades = const Value.absent(),
    this.snapDesejos = const Value.absent(),
    this.snapPoupanca = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FechamentosMensaisCompanion.insert({
    required String mesReferencia,
    required double rendaTotal,
    this.totalNecessidade = const Value.absent(),
    this.totalDesejo = const Value.absent(),
    this.totalInvestimento = const Value.absent(),
    this.snapNecessidades = const Value.absent(),
    this.snapDesejos = const Value.absent(),
    this.snapPoupanca = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mesReferencia = Value(mesReferencia),
       rendaTotal = Value(rendaTotal);
  static Insertable<FechamentoMensalRow> custom({
    Expression<String>? mesReferencia,
    Expression<double>? rendaTotal,
    Expression<double>? totalNecessidade,
    Expression<double>? totalDesejo,
    Expression<double>? totalInvestimento,
    Expression<double>? snapNecessidades,
    Expression<double>? snapDesejos,
    Expression<double>? snapPoupanca,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (rendaTotal != null) 'renda_total': rendaTotal,
      if (totalNecessidade != null) 'total_necessidade': totalNecessidade,
      if (totalDesejo != null) 'total_desejo': totalDesejo,
      if (totalInvestimento != null) 'total_investimento': totalInvestimento,
      if (snapNecessidades != null) 'snap_necessidades': snapNecessidades,
      if (snapDesejos != null) 'snap_desejos': snapDesejos,
      if (snapPoupanca != null) 'snap_poupanca': snapPoupanca,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FechamentosMensaisCompanion copyWith({
    Value<String>? mesReferencia,
    Value<double>? rendaTotal,
    Value<double>? totalNecessidade,
    Value<double>? totalDesejo,
    Value<double>? totalInvestimento,
    Value<double>? snapNecessidades,
    Value<double>? snapDesejos,
    Value<double>? snapPoupanca,
    Value<int>? rowid,
  }) {
    return FechamentosMensaisCompanion(
      mesReferencia: mesReferencia ?? this.mesReferencia,
      rendaTotal: rendaTotal ?? this.rendaTotal,
      totalNecessidade: totalNecessidade ?? this.totalNecessidade,
      totalDesejo: totalDesejo ?? this.totalDesejo,
      totalInvestimento: totalInvestimento ?? this.totalInvestimento,
      snapNecessidades: snapNecessidades ?? this.snapNecessidades,
      snapDesejos: snapDesejos ?? this.snapDesejos,
      snapPoupanca: snapPoupanca ?? this.snapPoupanca,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<String>(mesReferencia.value);
    }
    if (rendaTotal.present) {
      map['renda_total'] = Variable<double>(rendaTotal.value);
    }
    if (totalNecessidade.present) {
      map['total_necessidade'] = Variable<double>(totalNecessidade.value);
    }
    if (totalDesejo.present) {
      map['total_desejo'] = Variable<double>(totalDesejo.value);
    }
    if (totalInvestimento.present) {
      map['total_investimento'] = Variable<double>(totalInvestimento.value);
    }
    if (snapNecessidades.present) {
      map['snap_necessidades'] = Variable<double>(snapNecessidades.value);
    }
    if (snapDesejos.present) {
      map['snap_desejos'] = Variable<double>(snapDesejos.value);
    }
    if (snapPoupanca.present) {
      map['snap_poupanca'] = Variable<double>(snapPoupanca.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FechamentosMensaisCompanion(')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('rendaTotal: $rendaTotal, ')
          ..write('totalNecessidade: $totalNecessidade, ')
          ..write('totalDesejo: $totalDesejo, ')
          ..write('totalInvestimento: $totalInvestimento, ')
          ..write('snapNecessidades: $snapNecessidades, ')
          ..write('snapDesejos: $snapDesejos, ')
          ..write('snapPoupanca: $snapPoupanca, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntradasTable entradas = $EntradasTable(this);
  late final $ContasTable contas = $ContasTable(this);
  late final $OcorrenciasContaTable ocorrenciasConta = $OcorrenciasContaTable(
    this,
  );
  late final $CartoesTable cartoes = $CartoesTable(this);
  late final $FaturasCartaoTable faturasCartao = $FaturasCartaoTable(this);
  late final $RateiosFaturaTable rateiosFatura = $RateiosFaturaTable(this);
  late final $ConfiguracoesMetodologiaTable configuracoesMetodologia =
      $ConfiguracoesMetodologiaTable(this);
  late final $FechamentosMensaisTable fechamentosMensais =
      $FechamentosMensaisTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entradas,
    contas,
    ocorrenciasConta,
    cartoes,
    faturasCartao,
    rateiosFatura,
    configuracoesMetodologia,
    fechamentosMensais,
  ];
}

typedef $$EntradasTableCreateCompanionBuilder =
    EntradasCompanion Function({
      Value<int> id,
      required String nome,
      required double valorLiquido,
      required TipoEntrada tipo,
      Value<int?> diaRecebimento,
      Value<String?> mesReferencia,
      Value<String?> pausadaDesde,
      Value<String?> retomadaEm,
    });
typedef $$EntradasTableUpdateCompanionBuilder =
    EntradasCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<double> valorLiquido,
      Value<TipoEntrada> tipo,
      Value<int?> diaRecebimento,
      Value<String?> mesReferencia,
      Value<String?> pausadaDesde,
      Value<String?> retomadaEm,
    });

class $$EntradasTableFilterComposer
    extends Composer<_$AppDatabase, $EntradasTable> {
  $$EntradasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorLiquido => $composableBuilder(
    column: $table.valorLiquido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoEntrada, TipoEntrada, int> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get diaRecebimento => $composableBuilder(
    column: $table.diaRecebimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pausadaDesde => $composableBuilder(
    column: $table.pausadaDesde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retomadaEm => $composableBuilder(
    column: $table.retomadaEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntradasTableOrderingComposer
    extends Composer<_$AppDatabase, $EntradasTable> {
  $$EntradasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorLiquido => $composableBuilder(
    column: $table.valorLiquido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaRecebimento => $composableBuilder(
    column: $table.diaRecebimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pausadaDesde => $composableBuilder(
    column: $table.pausadaDesde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retomadaEm => $composableBuilder(
    column: $table.retomadaEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntradasTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntradasTable> {
  $$EntradasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<double> get valorLiquido => $composableBuilder(
    column: $table.valorLiquido,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoEntrada, int> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get diaRecebimento => $composableBuilder(
    column: $table.diaRecebimento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pausadaDesde => $composableBuilder(
    column: $table.pausadaDesde,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retomadaEm => $composableBuilder(
    column: $table.retomadaEm,
    builder: (column) => column,
  );
}

class $$EntradasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntradasTable,
          EntradaRow,
          $$EntradasTableFilterComposer,
          $$EntradasTableOrderingComposer,
          $$EntradasTableAnnotationComposer,
          $$EntradasTableCreateCompanionBuilder,
          $$EntradasTableUpdateCompanionBuilder,
          (
            EntradaRow,
            BaseReferences<_$AppDatabase, $EntradasTable, EntradaRow>,
          ),
          EntradaRow,
          PrefetchHooks Function()
        > {
  $$EntradasTableTableManager(_$AppDatabase db, $EntradasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntradasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntradasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntradasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<double> valorLiquido = const Value.absent(),
                Value<TipoEntrada> tipo = const Value.absent(),
                Value<int?> diaRecebimento = const Value.absent(),
                Value<String?> mesReferencia = const Value.absent(),
                Value<String?> pausadaDesde = const Value.absent(),
                Value<String?> retomadaEm = const Value.absent(),
              }) => EntradasCompanion(
                id: id,
                nome: nome,
                valorLiquido: valorLiquido,
                tipo: tipo,
                diaRecebimento: diaRecebimento,
                mesReferencia: mesReferencia,
                pausadaDesde: pausadaDesde,
                retomadaEm: retomadaEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required double valorLiquido,
                required TipoEntrada tipo,
                Value<int?> diaRecebimento = const Value.absent(),
                Value<String?> mesReferencia = const Value.absent(),
                Value<String?> pausadaDesde = const Value.absent(),
                Value<String?> retomadaEm = const Value.absent(),
              }) => EntradasCompanion.insert(
                id: id,
                nome: nome,
                valorLiquido: valorLiquido,
                tipo: tipo,
                diaRecebimento: diaRecebimento,
                mesReferencia: mesReferencia,
                pausadaDesde: pausadaDesde,
                retomadaEm: retomadaEm,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntradasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntradasTable,
      EntradaRow,
      $$EntradasTableFilterComposer,
      $$EntradasTableOrderingComposer,
      $$EntradasTableAnnotationComposer,
      $$EntradasTableCreateCompanionBuilder,
      $$EntradasTableUpdateCompanionBuilder,
      (EntradaRow, BaseReferences<_$AppDatabase, $EntradasTable, EntradaRow>),
      EntradaRow,
      PrefetchHooks Function()
    >;
typedef $$ContasTableCreateCompanionBuilder =
    ContasCompanion Function({
      Value<int> id,
      required String nome,
      required Grupo grupo,
      required double valorPlanejado,
      required int diaVencimento,
      required Recorrencia recorrencia,
      Value<int?> totalParcelas,
      Value<bool> ativa,
    });
typedef $$ContasTableUpdateCompanionBuilder =
    ContasCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<Grupo> grupo,
      Value<double> valorPlanejado,
      Value<int> diaVencimento,
      Value<Recorrencia> recorrencia,
      Value<int?> totalParcelas,
      Value<bool> ativa,
    });

final class $$ContasTableReferences
    extends BaseReferences<_$AppDatabase, $ContasTable, ContaRow> {
  $$ContasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OcorrenciasContaTable, List<OcorrenciaContaRow>>
  _ocorrenciasContaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ocorrenciasConta,
    aliasName: 'contas__id__ocorrencias_conta__conta_id',
  );

  $$OcorrenciasContaTableProcessedTableManager get ocorrenciasContaRefs {
    final manager = $$OcorrenciasContaTableTableManager(
      $_db,
      $_db.ocorrenciasConta,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _ocorrenciasContaRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContasTableFilterComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Grupo, Grupo, int> get grupo =>
      $composableBuilder(
        column: $table.grupo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Recorrencia, Recorrencia, int>
  get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ocorrenciasContaRefs(
    Expression<bool> Function($$OcorrenciasContaTableFilterComposer f) f,
  ) {
    final $$OcorrenciasContaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocorrenciasConta,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcorrenciasContaTableFilterComposer(
            $db: $db,
            $table: $db.ocorrenciasConta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContasTableOrderingComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContasTable> {
  $$ContasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Grupo, int> get grupo =>
      $composableBuilder(column: $table.grupo, builder: (column) => column);

  GeneratedColumn<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Recorrencia, int> get recorrencia =>
      $composableBuilder(
        column: $table.recorrencia,
        builder: (column) => column,
      );

  GeneratedColumn<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  Expression<T> ocorrenciasContaRefs<T extends Object>(
    Expression<T> Function($$OcorrenciasContaTableAnnotationComposer a) f,
  ) {
    final $$OcorrenciasContaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ocorrenciasConta,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OcorrenciasContaTableAnnotationComposer(
            $db: $db,
            $table: $db.ocorrenciasConta,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContasTable,
          ContaRow,
          $$ContasTableFilterComposer,
          $$ContasTableOrderingComposer,
          $$ContasTableAnnotationComposer,
          $$ContasTableCreateCompanionBuilder,
          $$ContasTableUpdateCompanionBuilder,
          (ContaRow, $$ContasTableReferences),
          ContaRow,
          PrefetchHooks Function({bool ocorrenciasContaRefs})
        > {
  $$ContasTableTableManager(_$AppDatabase db, $ContasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<Grupo> grupo = const Value.absent(),
                Value<double> valorPlanejado = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<Recorrencia> recorrencia = const Value.absent(),
                Value<int?> totalParcelas = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => ContasCompanion(
                id: id,
                nome: nome,
                grupo: grupo,
                valorPlanejado: valorPlanejado,
                diaVencimento: diaVencimento,
                recorrencia: recorrencia,
                totalParcelas: totalParcelas,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required Grupo grupo,
                required double valorPlanejado,
                required int diaVencimento,
                required Recorrencia recorrencia,
                Value<int?> totalParcelas = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => ContasCompanion.insert(
                id: id,
                nome: nome,
                grupo: grupo,
                valorPlanejado: valorPlanejado,
                diaVencimento: diaVencimento,
                recorrencia: recorrencia,
                totalParcelas: totalParcelas,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ContasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({ocorrenciasContaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ocorrenciasContaRefs) db.ocorrenciasConta,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ocorrenciasContaRefs)
                    await $_getPrefetchedData<
                      ContaRow,
                      $ContasTable,
                      OcorrenciaContaRow
                    >(
                      currentTable: table,
                      referencedTable: $$ContasTableReferences
                          ._ocorrenciasContaRefsTable(db),
                      managerFromTypedResult: (p0) => $$ContasTableReferences(
                        db,
                        table,
                        p0,
                      ).ocorrenciasContaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContasTable,
      ContaRow,
      $$ContasTableFilterComposer,
      $$ContasTableOrderingComposer,
      $$ContasTableAnnotationComposer,
      $$ContasTableCreateCompanionBuilder,
      $$ContasTableUpdateCompanionBuilder,
      (ContaRow, $$ContasTableReferences),
      ContaRow,
      PrefetchHooks Function({bool ocorrenciasContaRefs})
    >;
typedef $$OcorrenciasContaTableCreateCompanionBuilder =
    OcorrenciasContaCompanion Function({
      Value<int> id,
      required int contaId,
      required String mesReferencia,
      required double valorPlanejado,
      Value<double?> valorPago,
      Value<DateTime?> dataPagamento,
      Value<StatusPagamento> status,
      Value<int?> parcelaAtual,
      Value<bool> removida,
    });
typedef $$OcorrenciasContaTableUpdateCompanionBuilder =
    OcorrenciasContaCompanion Function({
      Value<int> id,
      Value<int> contaId,
      Value<String> mesReferencia,
      Value<double> valorPlanejado,
      Value<double?> valorPago,
      Value<DateTime?> dataPagamento,
      Value<StatusPagamento> status,
      Value<int?> parcelaAtual,
      Value<bool> removida,
    });

final class $$OcorrenciasContaTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OcorrenciasContaTable,
          OcorrenciaContaRow
        > {
  $$OcorrenciasContaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContasTable _contaIdTable(_$AppDatabase db) =>
      db.contas.createAlias('ocorrencias_conta__conta_id__contas__id');

  $$ContasTableProcessedTableManager get contaId {
    final $_column = $_itemColumn<int>('conta_id')!;

    final manager = $$ContasTableTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OcorrenciasContaTableFilterComposer
    extends Composer<_$AppDatabase, $OcorrenciasContaTable> {
  $$OcorrenciasContaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusPagamento, StatusPagamento, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get removida => $composableBuilder(
    column: $table.removida,
    builder: (column) => ColumnFilters(column),
  );

  $$ContasTableFilterComposer get contaId {
    final $$ContasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasContaTableOrderingComposer
    extends Composer<_$AppDatabase, $OcorrenciasContaTable> {
  $$OcorrenciasContaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get removida => $composableBuilder(
    column: $table.removida,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContasTableOrderingComposer get contaId {
    final $$ContasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasContaTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcorrenciasContaTable> {
  $$OcorrenciasContaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorPlanejado => $composableBuilder(
    column: $table.valorPlanejado,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorPago =>
      $composableBuilder(column: $table.valorPago, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StatusPagamento, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get removida =>
      $composableBuilder(column: $table.removida, builder: (column) => column);

  $$ContasTableAnnotationComposer get contaId {
    final $$ContasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContasTableAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OcorrenciasContaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OcorrenciasContaTable,
          OcorrenciaContaRow,
          $$OcorrenciasContaTableFilterComposer,
          $$OcorrenciasContaTableOrderingComposer,
          $$OcorrenciasContaTableAnnotationComposer,
          $$OcorrenciasContaTableCreateCompanionBuilder,
          $$OcorrenciasContaTableUpdateCompanionBuilder,
          (OcorrenciaContaRow, $$OcorrenciasContaTableReferences),
          OcorrenciaContaRow,
          PrefetchHooks Function({bool contaId})
        > {
  $$OcorrenciasContaTableTableManager(
    _$AppDatabase db,
    $OcorrenciasContaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcorrenciasContaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OcorrenciasContaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcorrenciasContaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contaId = const Value.absent(),
                Value<String> mesReferencia = const Value.absent(),
                Value<double> valorPlanejado = const Value.absent(),
                Value<double?> valorPago = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<StatusPagamento> status = const Value.absent(),
                Value<int?> parcelaAtual = const Value.absent(),
                Value<bool> removida = const Value.absent(),
              }) => OcorrenciasContaCompanion(
                id: id,
                contaId: contaId,
                mesReferencia: mesReferencia,
                valorPlanejado: valorPlanejado,
                valorPago: valorPago,
                dataPagamento: dataPagamento,
                status: status,
                parcelaAtual: parcelaAtual,
                removida: removida,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contaId,
                required String mesReferencia,
                required double valorPlanejado,
                Value<double?> valorPago = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<StatusPagamento> status = const Value.absent(),
                Value<int?> parcelaAtual = const Value.absent(),
                Value<bool> removida = const Value.absent(),
              }) => OcorrenciasContaCompanion.insert(
                id: id,
                contaId: contaId,
                mesReferencia: mesReferencia,
                valorPlanejado: valorPlanejado,
                valorPago: valorPago,
                dataPagamento: dataPagamento,
                status: status,
                parcelaAtual: parcelaAtual,
                removida: removida,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OcorrenciasContaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contaId,
                                referencedTable:
                                    $$OcorrenciasContaTableReferences
                                        ._contaIdTable(db),
                                referencedColumn:
                                    $$OcorrenciasContaTableReferences
                                        ._contaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OcorrenciasContaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OcorrenciasContaTable,
      OcorrenciaContaRow,
      $$OcorrenciasContaTableFilterComposer,
      $$OcorrenciasContaTableOrderingComposer,
      $$OcorrenciasContaTableAnnotationComposer,
      $$OcorrenciasContaTableCreateCompanionBuilder,
      $$OcorrenciasContaTableUpdateCompanionBuilder,
      (OcorrenciaContaRow, $$OcorrenciasContaTableReferences),
      OcorrenciaContaRow,
      PrefetchHooks Function({bool contaId})
    >;
typedef $$CartoesTableCreateCompanionBuilder =
    CartoesCompanion Function({
      Value<int> id,
      required String nome,
      required int diaVencimento,
      Value<bool> ativa,
    });
typedef $$CartoesTableUpdateCompanionBuilder =
    CartoesCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<int> diaVencimento,
      Value<bool> ativa,
    });

final class $$CartoesTableReferences
    extends BaseReferences<_$AppDatabase, $CartoesTable, CartaoRow> {
  $$CartoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FaturasCartaoTable, List<FaturaCartaoRow>>
  _faturasCartaoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.faturasCartao,
    aliasName: 'cartoes__id__faturas_cartao__cartao_id',
  );

  $$FaturasCartaoTableProcessedTableManager get faturasCartaoRefs {
    final manager = $$FaturasCartaoTableTableManager(
      $_db,
      $_db.faturasCartao,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_faturasCartaoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CartoesTableFilterComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> faturasCartaoRefs(
    Expression<bool> Function($$FaturasCartaoTableFilterComposer f) f,
  ) {
    final $$FaturasCartaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturasCartao,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasCartaoTableFilterComposer(
            $db: $db,
            $table: $db.faturasCartao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CartoesTableOrderingComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartoesTable> {
  $$CartoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  Expression<T> faturasCartaoRefs<T extends Object>(
    Expression<T> Function($$FaturasCartaoTableAnnotationComposer a) f,
  ) {
    final $$FaturasCartaoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturasCartao,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasCartaoTableAnnotationComposer(
            $db: $db,
            $table: $db.faturasCartao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CartoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartoesTable,
          CartaoRow,
          $$CartoesTableFilterComposer,
          $$CartoesTableOrderingComposer,
          $$CartoesTableAnnotationComposer,
          $$CartoesTableCreateCompanionBuilder,
          $$CartoesTableUpdateCompanionBuilder,
          (CartaoRow, $$CartoesTableReferences),
          CartaoRow,
          PrefetchHooks Function({bool faturasCartaoRefs})
        > {
  $$CartoesTableTableManager(_$AppDatabase db, $CartoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<bool> ativa = const Value.absent(),
              }) => CartoesCompanion(
                id: id,
                nome: nome,
                diaVencimento: diaVencimento,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int diaVencimento,
                Value<bool> ativa = const Value.absent(),
              }) => CartoesCompanion.insert(
                id: id,
                nome: nome,
                diaVencimento: diaVencimento,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CartoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({faturasCartaoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (faturasCartaoRefs) db.faturasCartao,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (faturasCartaoRefs)
                    await $_getPrefetchedData<
                      CartaoRow,
                      $CartoesTable,
                      FaturaCartaoRow
                    >(
                      currentTable: table,
                      referencedTable: $$CartoesTableReferences
                          ._faturasCartaoRefsTable(db),
                      managerFromTypedResult: (p0) => $$CartoesTableReferences(
                        db,
                        table,
                        p0,
                      ).faturasCartaoRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cartaoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CartoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartoesTable,
      CartaoRow,
      $$CartoesTableFilterComposer,
      $$CartoesTableOrderingComposer,
      $$CartoesTableAnnotationComposer,
      $$CartoesTableCreateCompanionBuilder,
      $$CartoesTableUpdateCompanionBuilder,
      (CartaoRow, $$CartoesTableReferences),
      CartaoRow,
      PrefetchHooks Function({bool faturasCartaoRefs})
    >;
typedef $$FaturasCartaoTableCreateCompanionBuilder =
    FaturasCartaoCompanion Function({
      Value<int> id,
      required int cartaoId,
      required String mesReferencia,
      Value<double?> valorTotal,
      Value<double?> valorPago,
      Value<DateTime?> dataPagamento,
      Value<StatusPagamento> status,
    });
typedef $$FaturasCartaoTableUpdateCompanionBuilder =
    FaturasCartaoCompanion Function({
      Value<int> id,
      Value<int> cartaoId,
      Value<String> mesReferencia,
      Value<double?> valorTotal,
      Value<double?> valorPago,
      Value<DateTime?> dataPagamento,
      Value<StatusPagamento> status,
    });

final class $$FaturasCartaoTableReferences
    extends
        BaseReferences<_$AppDatabase, $FaturasCartaoTable, FaturaCartaoRow> {
  $$FaturasCartaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CartoesTable _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('faturas_cartao__cartao_id__cartoes__id');

  $$CartoesTableProcessedTableManager get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id')!;

    final manager = $$CartoesTableTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RateiosFaturaTable, List<RateioFaturaRow>>
  _rateiosFaturaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rateiosFatura,
    aliasName: 'faturas_cartao__id__rateios_fatura__fatura_cartao_id',
  );

  $$RateiosFaturaTableProcessedTableManager get rateiosFaturaRefs {
    final manager = $$RateiosFaturaTableTableManager(
      $_db,
      $_db.rateiosFatura,
    ).filter((f) => f.faturaCartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rateiosFaturaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FaturasCartaoTableFilterComposer
    extends Composer<_$AppDatabase, $FaturasCartaoTable> {
  $$FaturasCartaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatusPagamento, StatusPagamento, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$CartoesTableFilterComposer get cartaoId {
    final $$CartoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rateiosFaturaRefs(
    Expression<bool> Function($$RateiosFaturaTableFilterComposer f) f,
  ) {
    final $$RateiosFaturaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rateiosFatura,
      getReferencedColumn: (t) => t.faturaCartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RateiosFaturaTableFilterComposer(
            $db: $db,
            $table: $db.rateiosFatura,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FaturasCartaoTableOrderingComposer
    extends Composer<_$AppDatabase, $FaturasCartaoTable> {
  $$FaturasCartaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorPago => $composableBuilder(
    column: $table.valorPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$CartoesTableOrderingComposer get cartaoId {
    final $$CartoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FaturasCartaoTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaturasCartaoTable> {
  $$FaturasCartaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorTotal => $composableBuilder(
    column: $table.valorTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorPago =>
      $composableBuilder(column: $table.valorPago, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPagamento => $composableBuilder(
    column: $table.dataPagamento,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StatusPagamento, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$CartoesTableAnnotationComposer get cartaoId {
    final $$CartoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartoesTableAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rateiosFaturaRefs<T extends Object>(
    Expression<T> Function($$RateiosFaturaTableAnnotationComposer a) f,
  ) {
    final $$RateiosFaturaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rateiosFatura,
      getReferencedColumn: (t) => t.faturaCartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RateiosFaturaTableAnnotationComposer(
            $db: $db,
            $table: $db.rateiosFatura,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FaturasCartaoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FaturasCartaoTable,
          FaturaCartaoRow,
          $$FaturasCartaoTableFilterComposer,
          $$FaturasCartaoTableOrderingComposer,
          $$FaturasCartaoTableAnnotationComposer,
          $$FaturasCartaoTableCreateCompanionBuilder,
          $$FaturasCartaoTableUpdateCompanionBuilder,
          (FaturaCartaoRow, $$FaturasCartaoTableReferences),
          FaturaCartaoRow,
          PrefetchHooks Function({bool cartaoId, bool rateiosFaturaRefs})
        > {
  $$FaturasCartaoTableTableManager(_$AppDatabase db, $FaturasCartaoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaturasCartaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaturasCartaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaturasCartaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaoId = const Value.absent(),
                Value<String> mesReferencia = const Value.absent(),
                Value<double?> valorTotal = const Value.absent(),
                Value<double?> valorPago = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<StatusPagamento> status = const Value.absent(),
              }) => FaturasCartaoCompanion(
                id: id,
                cartaoId: cartaoId,
                mesReferencia: mesReferencia,
                valorTotal: valorTotal,
                valorPago: valorPago,
                dataPagamento: dataPagamento,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaoId,
                required String mesReferencia,
                Value<double?> valorTotal = const Value.absent(),
                Value<double?> valorPago = const Value.absent(),
                Value<DateTime?> dataPagamento = const Value.absent(),
                Value<StatusPagamento> status = const Value.absent(),
              }) => FaturasCartaoCompanion.insert(
                id: id,
                cartaoId: cartaoId,
                mesReferencia: mesReferencia,
                valorTotal: valorTotal,
                valorPago: valorPago,
                dataPagamento: dataPagamento,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FaturasCartaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cartaoId = false, rateiosFaturaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rateiosFaturaRefs) db.rateiosFatura,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cartaoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cartaoId,
                                    referencedTable:
                                        $$FaturasCartaoTableReferences
                                            ._cartaoIdTable(db),
                                    referencedColumn:
                                        $$FaturasCartaoTableReferences
                                            ._cartaoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rateiosFaturaRefs)
                        await $_getPrefetchedData<
                          FaturaCartaoRow,
                          $FaturasCartaoTable,
                          RateioFaturaRow
                        >(
                          currentTable: table,
                          referencedTable: $$FaturasCartaoTableReferences
                              ._rateiosFaturaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FaturasCartaoTableReferences(
                                db,
                                table,
                                p0,
                              ).rateiosFaturaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.faturaCartaoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FaturasCartaoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FaturasCartaoTable,
      FaturaCartaoRow,
      $$FaturasCartaoTableFilterComposer,
      $$FaturasCartaoTableOrderingComposer,
      $$FaturasCartaoTableAnnotationComposer,
      $$FaturasCartaoTableCreateCompanionBuilder,
      $$FaturasCartaoTableUpdateCompanionBuilder,
      (FaturaCartaoRow, $$FaturasCartaoTableReferences),
      FaturaCartaoRow,
      PrefetchHooks Function({bool cartaoId, bool rateiosFaturaRefs})
    >;
typedef $$RateiosFaturaTableCreateCompanionBuilder =
    RateiosFaturaCompanion Function({
      Value<int> id,
      required int faturaCartaoId,
      required Grupo grupo,
      required double valor,
    });
typedef $$RateiosFaturaTableUpdateCompanionBuilder =
    RateiosFaturaCompanion Function({
      Value<int> id,
      Value<int> faturaCartaoId,
      Value<Grupo> grupo,
      Value<double> valor,
    });

final class $$RateiosFaturaTableReferences
    extends
        BaseReferences<_$AppDatabase, $RateiosFaturaTable, RateioFaturaRow> {
  $$RateiosFaturaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FaturasCartaoTable _faturaCartaoIdTable(_$AppDatabase db) => db
      .faturasCartao
      .createAlias('rateios_fatura__fatura_cartao_id__faturas_cartao__id');

  $$FaturasCartaoTableProcessedTableManager get faturaCartaoId {
    final $_column = $_itemColumn<int>('fatura_cartao_id')!;

    final manager = $$FaturasCartaoTableTableManager(
      $_db,
      $_db.faturasCartao,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_faturaCartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RateiosFaturaTableFilterComposer
    extends Composer<_$AppDatabase, $RateiosFaturaTable> {
  $$RateiosFaturaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Grupo, Grupo, int> get grupo =>
      $composableBuilder(
        column: $table.grupo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  $$FaturasCartaoTableFilterComposer get faturaCartaoId {
    final $$FaturasCartaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaCartaoId,
      referencedTable: $db.faturasCartao,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasCartaoTableFilterComposer(
            $db: $db,
            $table: $db.faturasCartao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateiosFaturaTableOrderingComposer
    extends Composer<_$AppDatabase, $RateiosFaturaTable> {
  $$RateiosFaturaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  $$FaturasCartaoTableOrderingComposer get faturaCartaoId {
    final $$FaturasCartaoTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaCartaoId,
      referencedTable: $db.faturasCartao,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasCartaoTableOrderingComposer(
            $db: $db,
            $table: $db.faturasCartao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateiosFaturaTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateiosFaturaTable> {
  $$RateiosFaturaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Grupo, int> get grupo =>
      $composableBuilder(column: $table.grupo, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  $$FaturasCartaoTableAnnotationComposer get faturaCartaoId {
    final $$FaturasCartaoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.faturaCartaoId,
      referencedTable: $db.faturasCartao,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FaturasCartaoTableAnnotationComposer(
            $db: $db,
            $table: $db.faturasCartao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RateiosFaturaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RateiosFaturaTable,
          RateioFaturaRow,
          $$RateiosFaturaTableFilterComposer,
          $$RateiosFaturaTableOrderingComposer,
          $$RateiosFaturaTableAnnotationComposer,
          $$RateiosFaturaTableCreateCompanionBuilder,
          $$RateiosFaturaTableUpdateCompanionBuilder,
          (RateioFaturaRow, $$RateiosFaturaTableReferences),
          RateioFaturaRow,
          PrefetchHooks Function({bool faturaCartaoId})
        > {
  $$RateiosFaturaTableTableManager(_$AppDatabase db, $RateiosFaturaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateiosFaturaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateiosFaturaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateiosFaturaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> faturaCartaoId = const Value.absent(),
                Value<Grupo> grupo = const Value.absent(),
                Value<double> valor = const Value.absent(),
              }) => RateiosFaturaCompanion(
                id: id,
                faturaCartaoId: faturaCartaoId,
                grupo: grupo,
                valor: valor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int faturaCartaoId,
                required Grupo grupo,
                required double valor,
              }) => RateiosFaturaCompanion.insert(
                id: id,
                faturaCartaoId: faturaCartaoId,
                grupo: grupo,
                valor: valor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RateiosFaturaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({faturaCartaoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (faturaCartaoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.faturaCartaoId,
                                referencedTable: $$RateiosFaturaTableReferences
                                    ._faturaCartaoIdTable(db),
                                referencedColumn: $$RateiosFaturaTableReferences
                                    ._faturaCartaoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RateiosFaturaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RateiosFaturaTable,
      RateioFaturaRow,
      $$RateiosFaturaTableFilterComposer,
      $$RateiosFaturaTableOrderingComposer,
      $$RateiosFaturaTableAnnotationComposer,
      $$RateiosFaturaTableCreateCompanionBuilder,
      $$RateiosFaturaTableUpdateCompanionBuilder,
      (RateioFaturaRow, $$RateiosFaturaTableReferences),
      RateioFaturaRow,
      PrefetchHooks Function({bool faturaCartaoId})
    >;
typedef $$ConfiguracoesMetodologiaTableCreateCompanionBuilder =
    ConfiguracoesMetodologiaCompanion Function({
      Value<int> id,
      required String mesVigenciaInicial,
      Value<double> percentualNecessidades,
      Value<double> percentualDesejos,
      Value<double> percentualPoupanca,
    });
typedef $$ConfiguracoesMetodologiaTableUpdateCompanionBuilder =
    ConfiguracoesMetodologiaCompanion Function({
      Value<int> id,
      Value<String> mesVigenciaInicial,
      Value<double> percentualNecessidades,
      Value<double> percentualDesejos,
      Value<double> percentualPoupanca,
    });

class $$ConfiguracoesMetodologiaTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracoesMetodologiaTable> {
  $$ConfiguracoesMetodologiaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesVigenciaInicial => $composableBuilder(
    column: $table.mesVigenciaInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentualNecessidades => $composableBuilder(
    column: $table.percentualNecessidades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentualDesejos => $composableBuilder(
    column: $table.percentualDesejos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentualPoupanca => $composableBuilder(
    column: $table.percentualPoupanca,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracoesMetodologiaTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracoesMetodologiaTable> {
  $$ConfiguracoesMetodologiaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesVigenciaInicial => $composableBuilder(
    column: $table.mesVigenciaInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentualNecessidades => $composableBuilder(
    column: $table.percentualNecessidades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentualDesejos => $composableBuilder(
    column: $table.percentualDesejos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentualPoupanca => $composableBuilder(
    column: $table.percentualPoupanca,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracoesMetodologiaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracoesMetodologiaTable> {
  $$ConfiguracoesMetodologiaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mesVigenciaInicial => $composableBuilder(
    column: $table.mesVigenciaInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percentualNecessidades => $composableBuilder(
    column: $table.percentualNecessidades,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percentualDesejos => $composableBuilder(
    column: $table.percentualDesejos,
    builder: (column) => column,
  );

  GeneratedColumn<double> get percentualPoupanca => $composableBuilder(
    column: $table.percentualPoupanca,
    builder: (column) => column,
  );
}

class $$ConfiguracoesMetodologiaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracoesMetodologiaTable,
          ConfiguracaoMetodologiaRow,
          $$ConfiguracoesMetodologiaTableFilterComposer,
          $$ConfiguracoesMetodologiaTableOrderingComposer,
          $$ConfiguracoesMetodologiaTableAnnotationComposer,
          $$ConfiguracoesMetodologiaTableCreateCompanionBuilder,
          $$ConfiguracoesMetodologiaTableUpdateCompanionBuilder,
          (
            ConfiguracaoMetodologiaRow,
            BaseReferences<
              _$AppDatabase,
              $ConfiguracoesMetodologiaTable,
              ConfiguracaoMetodologiaRow
            >,
          ),
          ConfiguracaoMetodologiaRow,
          PrefetchHooks Function()
        > {
  $$ConfiguracoesMetodologiaTableTableManager(
    _$AppDatabase db,
    $ConfiguracoesMetodologiaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracoesMetodologiaTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ConfiguracoesMetodologiaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConfiguracoesMetodologiaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mesVigenciaInicial = const Value.absent(),
                Value<double> percentualNecessidades = const Value.absent(),
                Value<double> percentualDesejos = const Value.absent(),
                Value<double> percentualPoupanca = const Value.absent(),
              }) => ConfiguracoesMetodologiaCompanion(
                id: id,
                mesVigenciaInicial: mesVigenciaInicial,
                percentualNecessidades: percentualNecessidades,
                percentualDesejos: percentualDesejos,
                percentualPoupanca: percentualPoupanca,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mesVigenciaInicial,
                Value<double> percentualNecessidades = const Value.absent(),
                Value<double> percentualDesejos = const Value.absent(),
                Value<double> percentualPoupanca = const Value.absent(),
              }) => ConfiguracoesMetodologiaCompanion.insert(
                id: id,
                mesVigenciaInicial: mesVigenciaInicial,
                percentualNecessidades: percentualNecessidades,
                percentualDesejos: percentualDesejos,
                percentualPoupanca: percentualPoupanca,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracoesMetodologiaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracoesMetodologiaTable,
      ConfiguracaoMetodologiaRow,
      $$ConfiguracoesMetodologiaTableFilterComposer,
      $$ConfiguracoesMetodologiaTableOrderingComposer,
      $$ConfiguracoesMetodologiaTableAnnotationComposer,
      $$ConfiguracoesMetodologiaTableCreateCompanionBuilder,
      $$ConfiguracoesMetodologiaTableUpdateCompanionBuilder,
      (
        ConfiguracaoMetodologiaRow,
        BaseReferences<
          _$AppDatabase,
          $ConfiguracoesMetodologiaTable,
          ConfiguracaoMetodologiaRow
        >,
      ),
      ConfiguracaoMetodologiaRow,
      PrefetchHooks Function()
    >;
typedef $$FechamentosMensaisTableCreateCompanionBuilder =
    FechamentosMensaisCompanion Function({
      required String mesReferencia,
      required double rendaTotal,
      Value<double> totalNecessidade,
      Value<double> totalDesejo,
      Value<double> totalInvestimento,
      Value<double> snapNecessidades,
      Value<double> snapDesejos,
      Value<double> snapPoupanca,
      Value<int> rowid,
    });
typedef $$FechamentosMensaisTableUpdateCompanionBuilder =
    FechamentosMensaisCompanion Function({
      Value<String> mesReferencia,
      Value<double> rendaTotal,
      Value<double> totalNecessidade,
      Value<double> totalDesejo,
      Value<double> totalInvestimento,
      Value<double> snapNecessidades,
      Value<double> snapDesejos,
      Value<double> snapPoupanca,
      Value<int> rowid,
    });

class $$FechamentosMensaisTableFilterComposer
    extends Composer<_$AppDatabase, $FechamentosMensaisTable> {
  $$FechamentosMensaisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rendaTotal => $composableBuilder(
    column: $table.rendaTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalNecessidade => $composableBuilder(
    column: $table.totalNecessidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDesejo => $composableBuilder(
    column: $table.totalDesejo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalInvestimento => $composableBuilder(
    column: $table.totalInvestimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get snapNecessidades => $composableBuilder(
    column: $table.snapNecessidades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get snapDesejos => $composableBuilder(
    column: $table.snapDesejos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get snapPoupanca => $composableBuilder(
    column: $table.snapPoupanca,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FechamentosMensaisTableOrderingComposer
    extends Composer<_$AppDatabase, $FechamentosMensaisTable> {
  $$FechamentosMensaisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rendaTotal => $composableBuilder(
    column: $table.rendaTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalNecessidade => $composableBuilder(
    column: $table.totalNecessidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDesejo => $composableBuilder(
    column: $table.totalDesejo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalInvestimento => $composableBuilder(
    column: $table.totalInvestimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get snapNecessidades => $composableBuilder(
    column: $table.snapNecessidades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get snapDesejos => $composableBuilder(
    column: $table.snapDesejos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get snapPoupanca => $composableBuilder(
    column: $table.snapPoupanca,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FechamentosMensaisTableAnnotationComposer
    extends Composer<_$AppDatabase, $FechamentosMensaisTable> {
  $$FechamentosMensaisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rendaTotal => $composableBuilder(
    column: $table.rendaTotal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalNecessidade => $composableBuilder(
    column: $table.totalNecessidade,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDesejo => $composableBuilder(
    column: $table.totalDesejo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalInvestimento => $composableBuilder(
    column: $table.totalInvestimento,
    builder: (column) => column,
  );

  GeneratedColumn<double> get snapNecessidades => $composableBuilder(
    column: $table.snapNecessidades,
    builder: (column) => column,
  );

  GeneratedColumn<double> get snapDesejos => $composableBuilder(
    column: $table.snapDesejos,
    builder: (column) => column,
  );

  GeneratedColumn<double> get snapPoupanca => $composableBuilder(
    column: $table.snapPoupanca,
    builder: (column) => column,
  );
}

class $$FechamentosMensaisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FechamentosMensaisTable,
          FechamentoMensalRow,
          $$FechamentosMensaisTableFilterComposer,
          $$FechamentosMensaisTableOrderingComposer,
          $$FechamentosMensaisTableAnnotationComposer,
          $$FechamentosMensaisTableCreateCompanionBuilder,
          $$FechamentosMensaisTableUpdateCompanionBuilder,
          (
            FechamentoMensalRow,
            BaseReferences<
              _$AppDatabase,
              $FechamentosMensaisTable,
              FechamentoMensalRow
            >,
          ),
          FechamentoMensalRow,
          PrefetchHooks Function()
        > {
  $$FechamentosMensaisTableTableManager(
    _$AppDatabase db,
    $FechamentosMensaisTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FechamentosMensaisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FechamentosMensaisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FechamentosMensaisTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mesReferencia = const Value.absent(),
                Value<double> rendaTotal = const Value.absent(),
                Value<double> totalNecessidade = const Value.absent(),
                Value<double> totalDesejo = const Value.absent(),
                Value<double> totalInvestimento = const Value.absent(),
                Value<double> snapNecessidades = const Value.absent(),
                Value<double> snapDesejos = const Value.absent(),
                Value<double> snapPoupanca = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FechamentosMensaisCompanion(
                mesReferencia: mesReferencia,
                rendaTotal: rendaTotal,
                totalNecessidade: totalNecessidade,
                totalDesejo: totalDesejo,
                totalInvestimento: totalInvestimento,
                snapNecessidades: snapNecessidades,
                snapDesejos: snapDesejos,
                snapPoupanca: snapPoupanca,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mesReferencia,
                required double rendaTotal,
                Value<double> totalNecessidade = const Value.absent(),
                Value<double> totalDesejo = const Value.absent(),
                Value<double> totalInvestimento = const Value.absent(),
                Value<double> snapNecessidades = const Value.absent(),
                Value<double> snapDesejos = const Value.absent(),
                Value<double> snapPoupanca = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FechamentosMensaisCompanion.insert(
                mesReferencia: mesReferencia,
                rendaTotal: rendaTotal,
                totalNecessidade: totalNecessidade,
                totalDesejo: totalDesejo,
                totalInvestimento: totalInvestimento,
                snapNecessidades: snapNecessidades,
                snapDesejos: snapDesejos,
                snapPoupanca: snapPoupanca,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FechamentosMensaisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FechamentosMensaisTable,
      FechamentoMensalRow,
      $$FechamentosMensaisTableFilterComposer,
      $$FechamentosMensaisTableOrderingComposer,
      $$FechamentosMensaisTableAnnotationComposer,
      $$FechamentosMensaisTableCreateCompanionBuilder,
      $$FechamentosMensaisTableUpdateCompanionBuilder,
      (
        FechamentoMensalRow,
        BaseReferences<
          _$AppDatabase,
          $FechamentosMensaisTable,
          FechamentoMensalRow
        >,
      ),
      FechamentoMensalRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntradasTableTableManager get entradas =>
      $$EntradasTableTableManager(_db, _db.entradas);
  $$ContasTableTableManager get contas =>
      $$ContasTableTableManager(_db, _db.contas);
  $$OcorrenciasContaTableTableManager get ocorrenciasConta =>
      $$OcorrenciasContaTableTableManager(_db, _db.ocorrenciasConta);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db, _db.cartoes);
  $$FaturasCartaoTableTableManager get faturasCartao =>
      $$FaturasCartaoTableTableManager(_db, _db.faturasCartao);
  $$RateiosFaturaTableTableManager get rateiosFatura =>
      $$RateiosFaturaTableTableManager(_db, _db.rateiosFatura);
  $$ConfiguracoesMetodologiaTableTableManager get configuracoesMetodologia =>
      $$ConfiguracoesMetodologiaTableTableManager(
        _db,
        _db.configuracoesMetodologia,
      );
  $$FechamentosMensaisTableTableManager get fechamentosMensais =>
      $$FechamentosMensaisTableTableManager(_db, _db.fechamentosMensais);
}
