var svgOesNW,
    oesNWColors={
      oes_nw_kom:{color:{fill:'#23bef0'},grey:{fill:'#dcdcdc'}},
      oes_nw_arh:{color:{fill:'#00aaf0'},grey:{fill:'#c8c8c8'}},
      oes_nw_kar:{color:{fill:'#0082c8'},grey:{fill:'#8c8c8c'}},
      oes_nw_len:{color:{fill:'#0064b4'},grey:{fill:'#6e6e6e'}},
      oes_nw_psk:{color:{fill:'#003c82'},grey:{fill:'#464646'}},
      oes_nw_nov:{color:{fill:'#0050a0'},grey:{fill:'#5a5a5a'}},
      oes_nw_kol:{color:{fill:'#0096e1'},grey:{fill:'#aaaaaa'}},
      oes_nw_kal:{color:{fill:'#7dd2f5'},grey:{fill:'#e6e6e6'}},
    };

function initNWoes() {
  var oesArray=[];
  d3.xml('oes_nw_map.svg', "image/svg+xml", function(xml) {
  	document.getElementById('oes_nw_map_svg').appendChild(xml.documentElement);
  	svgOesNW=d3.select('#oes_nw_map_svg').select('svg');
    for (var oes in oesNWColors) oesArray.push({name:oes});
    svgOesNW.selectAll('.oes_nw_region').data(oesArray,function(d){ return d ? d.name: this.id;})
    stylesInitNWoes();
    colorRegionsNW();
    eventsInitNWoes();
  });
}

function stylesInitNWoes() {
  svgOesNW.select('#other_regions').selectAll('path')
    .attr('style','fill:#fafafa;stroke:#d2d2d2;stroke-width:1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10;')

  svgOesNW.selectAll('.oes_nw_popup').style('pointer-events','none').style('display','none');
  svgOesNW.selectAll('.oes_nw_name').style('pointer-events','none');

  svgOesNW.selectAll('text').selectAll('tspan')
    .style('font-family','PT Sans')
    .style('font-variant','normal')
    .style('font-weight','normal')
    .style('font-stretch','normal');

  svgOesNW.selectAll('.oes_nw_fill').selectAll('path')
    .style('fill-opacity','1')
    .style('fill-rule','nonzero')
    .style('stroke','#fff')
    .style('stroke-width','1px')
}

function colorRegionsNW(){
  svgOesNW.selectAll('.oes_nw_region')
    .each(function(d){
        svgOesNW.select('#'+d.name).select('.oes_nw_fill').selectAll('path')
          .style('fill',oesNWColors[d.name].color.fill);
      })
}

function greyRegionsNW(selectedOes){
  svgOesNW.selectAll('.oes_nw_fill').each(function(d){
      d3.select(this).selectAll('path')
        .style('fill',d.name==selectedOes ? oesNWColors[d.name].color.fill : oesNWColors[d.name].grey.fill);
    })
}

function eventsInitNWoes(){
  svgOesNW.selectAll('.oes_nw_region')
    .on('mouseover',function(d){
        greyRegionsNW(d.name);
        svgOesNW.selectAll('.oes_nw_name').style('display','none');
        svgOesNW.select('#'+d.name).selectAll('.oes_nw_name').style('display',null);
        svgOesNW.select('#'+d.name).selectAll('.oes_nw_popup').style('display',null);
      })
    .on('mouseout',function(d){
        colorRegionsNW();
        svgOesNW.selectAll('.oes_nw_popup').style('display','none');
        svgOesNW.selectAll('.oes_nw_name').style('display',null);
      })
}

initNWoes();
