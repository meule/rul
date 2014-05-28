var svgOesRu, oesArray=[],
    oesAnimaDur=300,
    oesColors={
      oes_center:{color:{fill:'#0082c8',stroke:'#00aeed',text:'#b4dcf5'},grey:{fill:'#8c8c8c'}},
      oes_nw:{color:{fill:'#0050a0',stroke:'#00aeed',text:'#b4dcf5'},grey:{fill:'#5a5a5a'}},
      oes_ural:{color:{fill:'#0096e1',stroke:'#00aeed',text:'#b4dcf5'},grey:{fill:'#aaaaaa'}},
      oes_volga:{color:{fill:'#0064b4',stroke:'#00aeed',text:'#b4dcf5'},grey:{fill:'#6e6e6e'}},
      oes_south:{color:{fill:'#7dd2f5',stroke:'#40c4f0',text:'#0082c8'},grey:{fill:'#e6e6e6'}},
      oes_sib:{color:{fill:'#00aaf0',stroke:'#40c4f0',text:'#b4dcf5'},grey:{fill:'#c8c8c8'}},
      oes_east:{color:{fill:'#23bef0',stroke:'#00aeed',text:'#0082c8'},grey:{fill:'#dcdcdc'}},
    };

function init() {
  d3.xml('oes_ru_map.svg', "image/svg+xml", function(xml) {
  	document.getElementById('oes_ru_map_svg').appendChild(xml.documentElement);
  	svgOesRu=d3.select('#oes_ru_map_svg').select('svg');
    for (var oes in oesColors) oesArray.push({name:oes});
    svgOesRu.select('#oes_paths').selectAll('.oes_region').data(oesArray,function(d){ return d ? d.name: this.id;})
    stylesInit();
    colorRegions();
    eventsInit();
  });
}

function stylesInit() {
  svgOesRu.selectAll('.oes_popup').style('pointer-events','none');
  svgOesRu.select('#oes_names').style('pointer-events','none');
  svgOesRu.selectAll('text').selectAll('tspan')
    .style('font-family','PT Sans')
    .style('font-variant','normal')
    .style('font-weight','normal')
    .style('font-stretch','normal');
  svgOesRu.selectAll('.region_fill').selectAll('path')
    .style('fill-opacity','1')
    .style('fill-rule','nonzero')
    .style('stroke','none')
  svgOesRu.selectAll('.region_stroke').selectAll('path')
    .style('fill','none')
    .style('stroke-width','1px')
    .style('stroke-linecap','round')
    .style('stroke-linejoin','round')
    .style('stroke-miterlimit','4')
    .style('stroke-opacity','1')
    .style('stroke-dasharray','none');
  svgOesRu.select('#legend').selectAll('path')
    .style('fill','none')
    .style('stroke-opacity','1')
    .style('stroke-dasharray','none');
  svgOesRu.selectAll('.oes_popup').style('display','none')
}

function colorRegions(){
  svgOesRu.selectAll('.oes_region')
    .each(function(d){
        svgOesRu.select('#'+d.name).select('.region_fill').selectAll('path')
          .style('fill',oesColors[d.name].color.fill);
        svgOesRu.select('#'+d.name).select('.region_stroke').selectAll('path')
          .style('stroke',oesColors[d.name].color.stroke);
        svgOesRu.selectAll('.'+d.name+'_name')
          .style('fill',oesColors[d.name].color.text);
      })
}

function greyRegions(selectedOes){
  svgOesRu.selectAll('.region_fill').each(function(d){
      d3.select(this).selectAll('path')
        .style('fill',d.name==selectedOes ? oesColors[d.name].color.fill : oesColors[d.name].grey.fill);
    })
  svgOesRu.selectAll('.region_stroke').selectAll('path').style('stroke','#d2d2d2');
  svgOesRu.select('#oes_names').selectAll('tspan').style('fill','#fff');
}

function eventsInit(){
  svgOesRu.selectAll('.oes_region')
    .on('mouseover',function(d){
        greyRegions(d.name);
        svgOesRu.select('#'+d.name+'_popup').style('display',null);
        svgOesRu.selectAll('.'+d.name+'_name').style('display','none');
      })
    .on('mouseout',function(d){
        colorRegions();
        svgOesRu.selectAll('.oes_popup').style('display','none');
        svgOesRu.selectAll('.'+d.name+'_name').style('display',null);
      })
}

init();
