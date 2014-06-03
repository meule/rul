var svgExp,
    expColors={
      exp_mur:{color:{fill:'#00aaf0'},grey:{fill:'#c8c8c8'}},
      exp_kar:{color:{fill:'#0082c8'},grey:{fill:'#8c8c8c'}},
      exp_len:{color:{fill:'#0064b4'},grey:{fill:'#6e6e6e'}},
      exp_nor:{color:{fill:'#b4dcf5'},grey:{fill:'#f0f0f0'}},
      exp_fin:{color:{fill:'#7dd2f5'},grey:{fill:'#e6e6e6'}}
    },
    group2region={
      exp_paz:['exp_mur','exp_fin'],
      exp_vuo:['exp_fin','exp_len'],
      exp_bor:['exp_mur','exp_nor']
    }

function initExp() {
  var expArray=[], expGroupsArray=[];
  d3.xml('exp_map.svg', "image/svg+xml", function(xml) {
  	document.getElementById('exp_map_svg').appendChild(xml.documentElement);
  	svgExp=d3.select('#exp_map_svg').select('svg');
    for (var exp in expColors) expArray.push({name:exp});
    svgExp.selectAll('.exp_region').data(expArray,function(d){ return d ? d.name: this.id;})
    for (var group in group2region) expGroupsArray.push({name:group});
    svgExp.selectAll('.exp_group').data(expGroupsArray,function(d){ return d ? d.name: this.id;})
    stylesInitExp();
    colorRegionsExp();
    eventsInitExp();
  });
}

function stylesInitExp() {
  svgExp.select('#exp_others').selectAll('path')
    .attr('style','fill:#fafafa;stroke:#d2d2d2;stroke-width:1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10;')

  svgExp.selectAll('.exp_popup').style('pointer-events','none').style('display','none');
  svgExp.selectAll('.exp_names').style('pointer-events','none');


  svgExp.selectAll('text').selectAll('tspan')
    .style('font-family','PT Sans')
    .style('font-variant','normal')
    .style('font-weight','normal')
    .style('font-stretch','normal');

  svgExp.selectAll('.exp_region').selectAll('path')
    .style('fill-opacity','1')
    .style('fill-rule','nonzero')
    .style('stroke','#fff')
    .style('stroke-width','1px')
}

function colorRegionsExp(){
  svgExp.selectAll('.exp_region')
    .each(function(d){
        svgExp.select('#'+d.name).selectAll('path')
          .style('fill',expColors[d.name].color.fill);
      })
}

function greyRegionsExp(selGroup){
  svgExp.selectAll('.exp_region')
    .each(function(d){
        svgExp.select('#'+d.name).selectAll('path')
          .style('fill', expColors[d.name].grey.fill );
      })
  group2region[selGroup].forEach(function(selExp){
    svgExp.select('#'+selExp).selectAll('path').style('fill',expColors[selExp].color.fill);
  })
}

function eventsInitExp(){
  svgExp.selectAll('.exp_group')
    .on('mouseover',function(d){
        greyRegionsExp(d.name);
        svgExp.select('#'+d.name).selectAll('.exp_popup').style('display',null);
      })
    .on('mouseout',function(d){
        colorRegionsExp();
        svgExp.selectAll('.exp_popup').style('display','none');
      })
}

initExp();
