import MainView from './MainView';
import React from 'react';
import ReactDOM from 'react-dom';
import RunMap from '../RunMap';

export default class PageShowView extends MainView {

  mount() {
    super.mount();
    const mapContainer = document.querySelector(".map");
    const waypoints = JSON.parse(mapContainer.getAttribute("data-waypoints"));

    if(waypoints.length > 0) {
      ReactDOM.render(<RunMap waypoints={waypoints} container={mapContainer}/>, mapContainer);
    }

    // const geocoder = new google.maps.Geocoder;
    // geocoder.geocode({'location': waypoints[0], 'bounds': waypoints}, (results, status) => {
    //   if (status === google.maps.GeocoderStatus.OK) {
    //     if (results[1]) {
    //       console.log(results);
    //     } else {
    //       console.log("no results found");
    //     }
    //   } else {
    //     console.log('Geocoder failed due to: ' + status);
    //   }
    // });
  }

  unmount() {
    super.unmount();
  }
}
