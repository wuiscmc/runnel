// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import React from 'react';
import ReactDOM from 'react-dom';
import RunMap from './RunMap';

const runs = document.getElementsByClassName('run-box');

const maps = Array.from(runs).map((run) => {
  let waypointsContainer = run.querySelector(".stats");

  let waypoints = JSON.parse(waypointsContainer.dataset["waypoints"]);
  let mapContainer = run.querySelector(".map2");
  if(waypoints.length > 0) {
    ReactDOM.render(<RunMap waypoints={waypoints} container={mapContainer}/>, mapContainer);
  } else {
    mapContainer.innerHTML = '<img src="/images/running-track-small.jpg" />'
  }

  return true;
})

