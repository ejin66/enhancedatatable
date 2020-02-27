import 'package:flutter/material.dart'
    hide DataTable, DataColumn, DataRow, DataCell;

import 'data_table.dart';

class EnhanceDataTable<T> extends StatefulWidget {
  final bool fixedFirstRow;
  final bool fixedFirstCol;
  final List<List<T>> rowsCells;
  final Widget Function(T data) cellBuilder;
  final double cellHeight;
  final double cellSpacing;
  final double Function(int columnIndex) columnWidth;
  final Color headerColor;
  final TextStyle headerTextStyle;
  final List<Color> cellAlternateColor;
  final TextStyle cellTextStyle;
  final bool showBorderLine;
  final Color borderColor;

  EnhanceDataTable({
    this.fixedFirstRow = false,
    this.fixedFirstCol = false,
    @required this.rowsCells,
    @required this.columnWidth,
    this.cellBuilder,
    this.cellHeight = 56.0,
    this.cellSpacing = 10.0,
    this.headerColor,
    this.cellAlternateColor,
    this.headerTextStyle,
    this.cellTextStyle,
    this.showBorderLine = true,
    this.borderColor,
  })  : assert(cellAlternateColor == null || cellAlternateColor.length == 2),
        assert(borderColor == null || showBorderLine);

  @override
  State<StatefulWidget> createState() => EnhanceDataTableState();
}

class EnhanceDataTableState<T> extends State<EnhanceDataTable<T>> {
  final _columnController = ScrollController();
  final _rowController = ScrollController();
  final _subTableYController = ScrollController();
  final _subTableXController = ScrollController();

  Widget _buildChild(double width, T data,
      {bool isTitle = false, bool isOdd = true}) {

  	var bgColor = Colors.white;

  	if (isTitle) {
			if (widget.headerColor != null) bgColor = widget.headerColor;
		} else {
  		if (widget.cellAlternateColor != null) bgColor = isOdd
					? widget.cellAlternateColor.first
					: widget.cellAlternateColor.last;
		}

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: widget.cellSpacing / 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: widget.showBorderLine ? Border(
					right: BorderSide(
						color: widget.borderColor ?? Colors.grey[300],
						width: 0.5,
					),
					bottom: BorderSide(
						color: widget.borderColor ?? Colors.grey[300],
						width: 0.5,
					),
				) : null,
      ),
      width: width + widget.cellSpacing,
      child: widget.cellBuilder?.call(data) ??
          Text(
            '$data',
            style: isTitle
                ? widget.headerTextStyle ??
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                : widget.cellTextStyle,
          ),
    );
  }

  Widget _buildFixedCol() {
    if (!widget.fixedFirstCol || widget.rowsCells.length < 2)
      return SizedBox.shrink();

    var rowIndex = 0;
    return DataTable(
        horizontalMargin: 0,
        columnSpacing: 0,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: [
          DataColumn(
            label: _buildChild(
                widget.columnWidth(0), widget.rowsCells.first.first,
                isTitle: true),
          ),
        ],
        rows: widget.rowsCells.sublist(1).map((c) {
          rowIndex++;
          return DataRow(cells: [
            DataCell(_buildChild(
              widget.columnWidth(0),
              c.first,
              isOdd: rowIndex % 2 == 1,
            ))
          ]);
        }).toList());
  }

  Widget _buildFixedRow() {
    if (!widget.fixedFirstRow) return SizedBox.shrink();

    var subIndex = 0;

    if (widget.fixedFirstCol) {
      subIndex = 1;
    }

    var subList = widget.rowsCells.first.sublist(subIndex);
    var i = 0;
    return DataTable(
        horizontalMargin: 0,
        columnSpacing: 0,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: subList.map((c) {
          return DataColumn(
              label: _buildChild(widget.columnWidth(subIndex + i++), c,
                  isTitle: true));
        }).toList(),
        rows: []);
  }

  Widget _buildSubTable() {
    if (widget.rowsCells.length < 2) {
      return SizedBox.shrink();
    }

    List<List<T>> subList = widget.rowsCells;

    var firstColumnIndex = 0;
    if (widget.fixedFirstCol) {
      firstColumnIndex = 1;
      subList = subList.map((e) => e.sublist(1)).toList();
    }
    var i = 0;
    var rowIndex = 0;
    return DataTable(
      horizontalMargin: 0,
      columnSpacing: 0,
      headingRowHeight: widget.cellHeight,
      dataRowHeight: widget.cellHeight,
      columns: subList.first
          .map(
            (c) => DataColumn(
              label: _buildChild(
                widget.columnWidth(firstColumnIndex + i++),
                c,
              ),
            ),
          )
          .toList(),
      rows: subList.sublist(1).map((row) {
        rowIndex++;
				var j = 0;
        return DataRow(
            cells: row.map((c) {
          return DataCell(
            _buildChild(widget.columnWidth(firstColumnIndex + j++), c,
                isOdd: rowIndex % 2 == 1),
          );
        }).toList());
      }).toList(),
    );
  }

  Widget _buildCornerCell() {
    if (!widget.fixedFirstCol || !widget.fixedFirstRow) {
      return SizedBox.shrink();
    }

    return DataTable(
        horizontalMargin: 0,
        columnSpacing: 0,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: [
          DataColumn(
            label: _buildChild(
                widget.columnWidth(0), widget.rowsCells.first.first,
                isTitle: true),
          )
        ],
        rows: []);
  }

  @override
  void initState() {
    super.initState();
    _subTableXController.addListener(() {
      _rowController.jumpTo(_subTableXController.position.pixels);
    });
    _subTableYController.addListener(() {
      if (_columnController.position.pixels ==
          _subTableYController.position.pixels || !widget.fixedFirstCol) return;

      _columnController.jumpTo(_subTableYController.position.pixels);
    });
    _columnController.addListener(() {
      if (_columnController.position.pixels ==
          _subTableYController.position.pixels) return;

      _subTableYController.jumpTo(_columnController.position.pixels);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
			decoration: widget.showBorderLine ? BoxDecoration(
				border: Border(
					left: BorderSide(
						color: widget.borderColor ?? Colors.grey[300],
						width: 0.5,
					),
					top: BorderSide(
						color: widget.borderColor ?? Colors.grey[300],
						width: 0.5,
					),
				),
			) : null,
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              SingleChildScrollView(
                controller: _columnController,
                scrollDirection: Axis.vertical,
//              physics: NeverScrollableScrollPhysics(),
                child: _buildFixedCol(),
              ),
              Flexible(
                child: SingleChildScrollView(
                  controller: _subTableXController,
                  scrollDirection: Axis.horizontal,
                  physics: ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    controller: _subTableYController,
                    scrollDirection: Axis.vertical,
                    child: _buildSubTable(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              _buildCornerCell(),
              Flexible(
                child: SingleChildScrollView(
                  controller: _rowController,
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  child: _buildFixedRow(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
