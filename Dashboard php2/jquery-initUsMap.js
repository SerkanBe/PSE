$(function initUsMap(){
  $('#us-map').vectorMap({map: 'us_aea',
  
  /* scaleColors: ['#C8EEFF', '#0071A4'], */
   /*  normalizeFunction: 'polynomial', */
   /*  hoverOpacity: 0.7, */
    /* hoverColor: false, */
  
  backgroundColor: '#d3d3d3',
  
  //REGION LABEL///////////////////
  
  regionLabelStyle: {
      initial: {
        fill: '#B90E32'
      },
      hover: {
        fill: 'black'
      }
    },
	
    labels: {
      regions: {
        render: function(code){
          var doNotShow = ['US-RI', 'US-DC', 'US-DE', 'US-MD'];

          if (doNotShow.indexOf(code) === -1) {
            return code.split('-')[1];
          }
        },
        offsets: function(code){
          return {
            'CA': [-10, 10],
            'ID': [0, 40],
            'OK': [25, 0],
            'LA': [-20, 0],
            'FL': [45, 0],
            'KY': [10, 5],
            'VA': [15, 5],
            'MI': [30, 30],
            'AK': [50, -25],
            'HI': [25, 50]
          }[code.split('-')[1]];
        }
      }
    },
	
//MARKER//////////////////////

  markerStyle: {
      initial: {
        fill: '#F8E23B',
        stroke: '#383f47'
      }
    },
  markers: [
      {latLng: [36.169941, -115.139830], name: 'Vatican City'}
     
    ]
  
  
  
  
  
  
  
  
  
  
  
  });
  });