var svgPro,
    proColors={
      sel:'#d7effd',
      nonSel:'#0073be',
      textNonSel:'#fafafa',
      textSel:'#0073be'
    },
    proRegs=['pro_mur','pro_kar','pro_len'];

function initPro() {
  var proArray=[], proGroupsArray=[];
  d3.xml('pro_map.svg', "image/svg+xml", function(xml) {
  	document.getElementById('pro_map_svg').appendChild(xml.documentElement);
  	svgPro=d3.select('#pro_map_svg').select('svg');
    svgPro.selectAll('.pro_reg').data(proRegs,function(d){ return d ? d: this.id;})
    stylesInitPro();
    colorRegionsPro();
    eventsInitPro();
  });
}

function stylesInitPro() {
 
  svgPro.selectAll('.popup').style('pointer-events','none').style('display','none');
  svgPro.select('#pro_others').selectAll('text').style('pointer-events','none');
  svgPro.select('#pro_others').selectAll('path').style('pointer-events','none');


  svgPro.selectAll('text').selectAll('tspan')
    .style('font-family','PT Sans')
    .style('font-variant','normal')
    .style('font-weight','normal')
    .style('font-stretch','normal');
}

function colorRegionsPro(){
  svgPro.selectAll('.reg_fill').selectAll('path').style('fill',proColors.nonSel);
  svgPro.selectAll('.pro_name').style('fill',proColors.textNonSel);
}

function greyRegionsPro(selReg){
  svgPro.select('#'+selReg).select('.reg_fill').selectAll('path').style('fill',proColors.sel);
  svgPro.selectAll('.name_'+selReg).style('fill',proColors.textSel);
}

function eventsInitPro(){
  svgPro.selectAll('.pro_reg')
    .on('mouseover',function(d){
        greyRegionsPro(d);
        svgPro.select('#popup_'+d).style('display',null);
      })
    .on('mouseout',function(d){
        colorRegionsPro();
        svgPro.selectAll('.popup').style('display','none');
      })
}

initPro();
