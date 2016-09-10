import React, { Component } from 'react';

class RunMap extends Component {
    static get defaultProps() {
      return {
        runTrack: new google.maps.Polyline(),
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
        draggable: false,
        scrollwheel: false,
        keyboardShortcuts: false,
        disableDoubleClickZoom: true
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
        <div className='map-canvas'></div>
      );
    }
}

export default RunMap;
