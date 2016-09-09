import MainView from './MainView';
import React from 'react';
import ReactDOM from 'react-dom';
import RunMap from '../RunMap';

export default class PageSee_stuffView extends MainView {

  mount() {
    super.mount();
    const runs = document.getElementsByClassName('run-box');

    const maps = Array.from(runs).map((run) => {
      let waypointsContainer = run.children[0].children[1]
      let waypoints = JSON.parse(waypointsContainer.dataset["waypoints"]);
      if(waypoints.length > 0) {
        ReactDOM.render(<RunMap waypoints={waypoints} container={run.querySelector(".map2")}/>, run.querySelector(".map2"));
      }

      return true;
    })


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
