import MainView from './MainView';
import ReactDOM from 'react-dom';
import React, { Component } from 'react';

class RunMap extends Component {
    static get defaultProps() {
      return {
        runTrack: new google.maps.Polyline(),
        container: document.getElementById('map'),
      }
    }

    componentDidMount() {
      var bounds = new google.maps.LatLngBounds();

      this.props.waypoints.forEach((waypoint) => {
        bounds.extend(new google.maps.LatLng(waypoint));
      });

      var map = new google.maps.Map(this.props.container, {
        zoom: 100,
        center: bounds.getCenter(),
        mapTypeId: google.maps.MapTypeId.TERRAIN
      });

      map.fitBounds(bounds);

      this.props.runTrack.setOptions({
        path: this.props.waypoints,
        geodesic: true,
        strokeColor: '#FF0000',
        strokeOpacity: 1.0,
        strokeWeight: 2
      });

      this.props.runTrack.setMap(map);
    }

    render () {
      return (
        <div id='map-canvas'></div>
      );
    }
}

export default class PageRunView extends MainView {

  mount() {
    super.mount();
    const mapContainer = document.getElementById('map');
    const waypoints = JSON.parse(mapContainer.getAttribute('data-waypoints'));

    if(waypoints.length > 0) {
      ReactDOM.render(<RunMap waypoints={waypoints} />, mapContainer);
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
