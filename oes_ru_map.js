var svg, oesArray=[],
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
  d3.xml('oes_ru_map3.svg', "image/svg+xml", function(xml) {
  	document.getElementById('oes_ru_map_svg').appendChild(xml.documentElement);
  	svg=d3.select('#oes_ru_map_svg').select('svg');
    for (var oes in oesColors) oesArray.push({name:oes});
    svg.select('#oes_paths').selectAll('.oes_region').data(oesArray,function(d){ return d ? d.name: this.id;})
    stylesInit();
    colorRegions();
    eventsInit();
  });
}

function stylesInit() {
  svg.selectAll('.oes_popup').style('pointer-events','none');
  svg.select('#oes_names').style('pointer-events','none');
  svg.selectAll('text').selectAll('tspan')
    .style('font-family','PT Sans')
    .style('font-variant','normal')
    .style('font-weight','normal')
    .style('font-stretch','normal');
  svg.selectAll('.region_fill').selectAll('path')
    .style('fill-opacity','1')
    .style('fill-rule','nonzero')
    .style('stroke','none')
  svg.selectAll('.region_stroke').selectAll('path')
    .style('fill','none')
    .style('stroke-width','0.54275')
    .style('stroke-linecap','round')
    .style('stroke-linejoin','round')
    .style('stroke-miterlimit','4')
    .style('stroke-opacity','1')
    .style('stroke-dasharray','none');
  svg.select('#legend').selectAll('path')
    .style('fill','none')
    .style('stroke-opacity','1')
    .style('stroke-dasharray','none');
  svg.selectAll('.oes_popup').style('opacity',0)
}

function colorRegions(){
  for(var oes in oesColors){
    svg.select('#'+oes+'_fill').selectAll('path').transition().duration(oesAnimaDur*1.5).style('fill',oesColors[oes].color.fill);
    svg.select('#'+oes+'_stroke').selectAll('path').transition().duration(oesAnimaDur*1.5).style('stroke',oesColors[oes].color.stroke);
    svg.select('#oes_names').selectAll('.'+oes+'_name').transition().duration(oesAnimaDur)
      .style('fill',oesColors[oes].color.text)
      .style('fill-opacity',1);
  }
}

function greyRegions(selectedOes){
  for(var oes in oesColors){
    if (selectedOes!=oes) {
      svg.select('#'+oes+'_fill').selectAll('path').transition().duration(oesAnimaDur*1.5).style('fill',oesColors[oes].grey.fill);
      svg.select('#oes_names').selectAll('.'+oes+'_name').transition().duration(oesAnimaDur)
        .style('fill','#fff')
        .style('fill-opacity',1);
    }
    svg.select('#'+oes+'_stroke').selectAll('path').transition().duration(oesAnimaDur*1.5).style('stroke','#d2d2d2');
  }
}

function eventsInit(){
  for(var oes in oesColors){
    svg.select('#'+oes)
      .on('mouseover',function(d){
          greyRegions(d.name);
          svg.select('#'+d.name+'_popup').transition().duration(oesAnimaDur).style('opacity',1);
          svg.select('#oes_names').selectAll('.'+d.name+'_name').transition().duration(oesAnimaDur).style('fill-opacity',0);
        })
      .on('mouseout',function(d){
          colorRegions();
          svg.selectAll('.oes_popup').transition().duration(oesAnimaDur).style('opacity',0)
          //svg.select('#oes_names').selectAll('tspan').transition().duration(oesAnimaDur);
        })
  }
}

init();
