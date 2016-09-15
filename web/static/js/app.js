import 'phoenix_html';
import React from 'react';
import ReactDOM from 'react-dom';

import RunMap from './RunMap';
// import socket from './socket'

const runs = document.getElementsByClassName('run');

const maps = Array.from(runs).map((run) => {
  let waypointsContainer = run.querySelector('.run-data');

  let waypoints = JSON.parse(waypointsContainer.dataset['waypoints']);
  let mapContainer = run.querySelector('.map');
  if(waypoints.length > 0) {
    ReactDOM.render(<RunMap waypoints={waypoints} container={mapContainer}/>, mapContainer);
  } else {
    mapContainer.innerHTML = '<img src="/images/running-track-small.jpg" />'
  }

  return true;
})

