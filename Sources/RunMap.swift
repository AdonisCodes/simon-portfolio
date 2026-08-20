import Foundation
import JavaScriptKit

func mountRunMap() {
    let document = JSObject.global.document
    guard document.getElementById("run-map").object != nil else { return }

    let travelJSON = travelMapJSON()
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "'", with: "\\'")

    _ = JSObject.global.eval.function!(
        JSValue.string(
            """
            (function() {
              if (typeof L === 'undefined') return;

              const travelData = JSON.parse('\(travelJSON)');
              const selectedColor = '#e8843a';
              const defaultColor = '#4fa760';
              const mutedOpacity = 0.35;
              const flightUiCollapseZoom = 7;

              const south = -85.05112878;
              const north = 85.05112878;
              const worldBounds = L.latLngBounds(L.latLng(south, -180), L.latLng(north, 180));

              function getMinZoomForHeight(map, size) {
                for (let z = 0; z <= 20; z++) {
                  const northY = map.project(L.latLng(north, 0), z).y;
                  const southY = map.project(L.latLng(south, 0), z).y;
                  if (southY - northY >= size.y) {
                    return z;
                  }
                }
                return 20;
              }

              function getMinZoomForWidth(map, size) {
                for (let z = 0; z <= 20; z++) {
                  const westX = map.project(L.latLng(0, -180), z).x;
                  const eastX = map.project(L.latLng(0, 180), z).x;
                  if (eastX - westX >= size.x) {
                    return z;
                  }
                }
                return 20;
              }

              function getMinZoom(map, size) {
                return Math.max(getMinZoomForHeight(map, size), getMinZoomForWidth(map, size));
              }

              function applyWorldLimits(map, preserveView) {
                map.invalidateSize();
                const size = map.getSize();
                if (size.y < 10 || size.x < 10) {
                  setTimeout(function() { applyWorldLimits(map, preserveView); }, 50);
                  return;
                }

                const minZoom = getMinZoom(map, size);
                map.setMinZoom(minZoom);
                map.setMaxBounds(worldBounds);

                let lat = 0;
                let lng = 0;
                let zoom = minZoom;

                if (preserveView) {
                  const center = map.getCenter();
                  lat = Math.max(south, Math.min(north, center.lat));
                  lng = Math.max(-180, Math.min(180, center.lng));
                  zoom = Math.max(minZoom, map.getZoom());
                }

                map.setView([lat, lng], zoom, { animate: false });
              }

              function setLayerStyle(layer, color, opacity, fillOpacity) {
                if (!layer || !layer.setStyle) return;
                layer.setStyle({
                  color: color,
                  opacity: opacity,
                  fillColor: color,
                  fillOpacity: fillOpacity,
                });
              }

              function updateMarkerDot(marker, selected) {
                if (!marker || !marker.getElement) return;
                const el = marker.getElement();
                if (!el) return;
                const dot = el.querySelector('.travel-marker-dot');
                if (!dot) return;
                dot.style.background = selected ? selectedColor : defaultColor;
                dot.style.boxShadow = selected
                  ? '0 0 0 2px rgba(232, 132, 58, 0.45)'
                  : '0 0 0 2px rgba(79, 167, 96, 0.35)';
                dot.style.opacity = selected ? '1' : String(mutedOpacity + 0.25);
              }

              function photoPopupHtml(photo, size) {
                return '<div class="map-photo-popup">' +
                  '<img src="' + photo.imageUrl + '" alt="" width="' + size + '" />' +
                  '<div class="map-photo-popup-caption">' + photo.caption + '</div>' +
                '</div>';
              }

              function createPhotoMarker(map, photo, kind) {
                const sizeClass = kind === 'flight' ? 'map-photo-dot-flight' : (kind === 'world' ? 'map-photo-dot-world' : 'map-photo-dot-spot');
                const marker = L.marker([photo.lat, photo.lng], {
                  icon: L.divIcon({
                    className: 'map-photo-marker',
                    html: '<div class="map-photo-dot ' + sizeClass + '"><img src="' + photo.imageUrl + '" alt="" /></div>',
                  }),
                });
                marker.bindPopup(photoPopupHtml(photo, 180), {
                  className: 'map-photo-popup-wrap',
                  maxWidth: 220,
                });
                marker.on('click', function(e) {
                  L.DomEvent.stopPropagation(e);
                });
                marker.addTo(map);
                window.__travelLayers.push(marker);
                return marker;
              }

              function setPhotoMarkerOpacity(marker, opacity) {
                if (!marker || !marker.getElement) return;
                const el = marker.getElement();
                if (el) {
                  el.style.opacity = String(opacity);
                  el.style.pointerEvents = opacity > 0.05 ? 'auto' : 'none';
                }
              }

              function updatePhotoVisibility(selectedId) {
                Object.entries(window.__photoLayersByActivity || {}).forEach(function(entry) {
                  const activityId = entry[0];
                  const layers = entry[1];
                  const isSelected = selectedId && activityId === selectedId;
                  const isOverview = !selectedId;
                  const opacity = isSelected ? 1 : (isOverview ? 0.75 : 0.2);

                  layers.spots.forEach(function(marker) {
                    setPhotoMarkerOpacity(marker, isSelected || isOverview ? opacity : 0.15);
                  });
                  layers.flightPhotos.forEach(function(marker) {
                    if (!isSelected || window.__flightUiCollapsed) {
                      setPhotoMarkerOpacity(marker, 0);
                      return;
                    }
                    setPhotoMarkerOpacity(marker, 1);
                  });
                });

                (window.__worldPhotoLayers || []).forEach(function(marker) {
                  setPhotoMarkerOpacity(marker, 0.8);
                });
              }
              function updateActivityStyles(selectedId) {
                Object.entries(window.__activityLayers || {}).forEach(function(entry) {
                  const id = entry[0];
                  const layers = entry[1];
                  const selected = selectedId && id === selectedId;
                  const color = selected ? selectedColor : defaultColor;
                  const opacity = selected ? 0.95 : mutedOpacity;
                  const fillOpacity = selected ? 0.1 : 0.03;

                  setLayerStyle(layers.region, color, opacity, fillOpacity);
                  if (layers.route) {
                    setLayerStyle(layers.route, color, opacity, 0);
                  }
                  updateMarkerDot(layers.marker, selected);
                });

                Object.entries(window.__flightLayersByActivity || {}).forEach(function(entry) {
                  const activityId = entry[0];
                  const layers = entry[1];
                  const isSelected = selectedId && activityId === selectedId;
                  const isOverview = !selectedId;
                  const collapsed = window.__flightUiCollapsed;
                  const pathOpacity = isSelected ? 0.75 : (isOverview ? 0.4 : 0);
                  const showFlightLabels = isSelected && !collapsed;
                  const labelOpacity = showFlightLabels ? '1' : '0';

                  layers.forEach(function(layer) {
                    if (layer.__flightRole === 'path' && layer.setStyle) {
                      layer.setStyle({ opacity: pathOpacity });
                    }
                    if (layer.__flightRole === 'label' && layer.getElement) {
                      const el = layer.getElement();
                      if (el) {
                        el.style.opacity = labelOpacity;
                        el.style.pointerEvents = showFlightLabels ? 'auto' : 'none';
                      }
                    }
                  });
                });

                updatePhotoVisibility(selectedId);
              }

              function zoomToActivity(activity) {
                if (!window.__runMap || !activity) return;
                const bounds = L.latLngBounds(activity.bounds);
                if (!bounds.isValid()) return;
                bounds.pad(0.35);
                window.__runMap.flyToBounds(bounds, {
                  duration: 2.8,
                  easeLinearity: 0.22,
                  padding: [100, 100],
                  maxZoom: 9,
                });
              }

              function zoomToWorld(map) {
                map.invalidateSize();
                const size = map.getSize();
                if (size.y < 10 || size.x < 10) return;
                const minZoom = getMinZoom(map, size);
                map.setMinZoom(minZoom);
                map.setMaxBounds(worldBounds);
                map.flyTo([0, 0], minZoom, {
                  duration: 2.5,
                  easeLinearity: 0.22,
                });
              }

              function setDetailOpen(isOpen) {
                const detailView = document.querySelector('.activity-detail-view');
                const drawerBody = document.querySelector('.stats-drawer-body');
                const drawer = document.querySelector('.stats-drawer');
                if (detailView) {
                  detailView.classList.toggle('open', isOpen);
                }
                if (drawerBody) {
                  drawerBody.classList.toggle('has-detail', isOpen);
                }
                if (drawer) {
                  drawer.classList.toggle('detail-open', isOpen);
                }
              }

              function flightCurve(from, to, direction) {
                const latDiff = from[0] - to[0];
                const lngDiff = from[1] - to[1];
                const span = Math.sqrt((latDiff * latDiff) + (lngDiff * lngDiff));
                const sign = direction === 'Outbound' ? 1 : -1;
                const bend = sign * Math.min(8, Math.max(0.6, span * 0.1));
                const mid = [
                  (from[0] + to[0]) / 2 + bend,
                  (from[1] + to[1]) / 2,
                ];

                function pointOnCurve(t) {
                  const u = 1 - t;
                  return [
                    u * u * from[0] + 2 * u * t * mid[0] + t * t * to[0],
                    u * u * from[1] + 2 * u * t * mid[1] + t * t * to[1],
                  ];
                }

                function samplePoints(steps) {
                  const points = [];
                  for (let i = 0; i <= steps; i++) {
                    points.push(pointOnCurve(i / steps));
                  }
                  return points;
                }

                function pointOnPath(t) {
                  return pointOnCurve(t);
                }

                return { mid: mid, pointOnCurve: pointOnCurve, pointOnPath: pointOnPath, samplePoints: samplePoints };
              }

              window.__openActivity = function(id, shouldZoom) {
                if (shouldZoom === undefined) shouldZoom = true;

                document.querySelectorAll('.activity-item').forEach(function(el) {
                  el.classList.toggle('selected', el.id === 'activity-item-' + id);
                });

                document.querySelectorAll('.activity-detail').forEach(function(el) {
                  el.classList.toggle('active', el.id === 'activity-detail-' + id);
                });

                setDetailOpen(true);
                updateActivityStyles(id);
                window.__selectedActivityId = id;

                if (shouldZoom) {
                  const activity = travelData.activities.find(function(item) {
                    return item.id === id;
                  });
                  zoomToActivity(activity);
                }
              };

              window.__closeActivity = function() {
                document.querySelectorAll('.activity-item').forEach(function(el) {
                  el.classList.remove('selected');
                });

                document.querySelectorAll('.activity-detail').forEach(function(el) {
                  el.classList.remove('active');
                });

                setDetailOpen(false);
                updateActivityStyles(null);
                window.__selectedActivityId = null;

                if (window.__runMap) {
                  zoomToWorld(window.__runMap);
                }
              };

              function updateFlightCollapse(map) {
                if (!map) return;
                window.__flightUiCollapsed = map.getZoom() <= flightUiCollapseZoom;
                updateActivityStyles(window.__selectedActivityId || null);
              }

              function bindFlightActivity(layer, activityId) {
                layer.on('click', function(e) {
                  L.DomEvent.stopPropagation(e);
                  window.__openActivity(activityId, true);
                });
              }

              function drawFlightsForActivity(map, activity) {
                const layers = [];
                const flightPhotos = [];

                activity.flights.forEach(function(flight) {
                  const from = [flight.fromLat, flight.fromLng];
                  const to = [flight.toLat, flight.toLng];
                  const curve = flightCurve(from, to, flight.direction);

                  const pathPoints = curve.samplePoints(32);

                  const path = L.polyline(pathPoints, {
                    color: '#ffffff',
                    weight: 3,
                    opacity: 0,
                    dashArray: '8 8',
                    className: 'flight-path-clickable',
                  });
                  path.__flightRole = 'path';
                  bindFlightActivity(path, activity.id);
                  path.addTo(map);
                  window.__travelLayers.push(path);
                  layers.push(path);

                  const labelT = flight.direction === 'Outbound' ? 0.42 : 0.58;
                  const labelPos = curve.pointOnPath(labelT);

                  const label = L.marker(labelPos, {
                    icon: L.divIcon({
                      className: 'flight-marker',
                      html: '<div class="flight-marker-label ' + flight.direction.toLowerCase() + '"><div class="flight-marker-route">' + flight.fromCode + ' to ' + flight.toCode + '</div><div class="flight-marker-meta">' + flight.date + ' · ' + flight.duration + '</div></div>',
                      iconSize: [1, 1],
                      iconAnchor: [0, 0],
                    }),
                  });
                  label.__flightRole = 'label';
                  bindFlightActivity(label, activity.id);
                  label.addTo(map);
                  window.__travelLayers.push(label);
                  layers.push(label);

                  (flight.photos || []).forEach(function(photo) {
                    const pos = curve.pointOnPath(photo.t);
                    const marker = createPhotoMarker(map, {
                      lat: pos[0],
                      lng: pos[1],
                      imageUrl: photo.imageUrl,
                      caption: photo.caption,
                    }, 'flight');
                    flightPhotos.push(marker);
                  });
                });

                window.__flightLayersByActivity[activity.id] = layers;
                if (!window.__photoLayersByActivity[activity.id]) {
                  window.__photoLayersByActivity[activity.id] = { spots: [], flightPhotos: [] };
                }
                window.__photoLayersByActivity[activity.id].flightPhotos = flightPhotos;
              }

              function drawTravelLayers(map) {
                if (window.__travelLayers) {
                  window.__travelLayers.forEach(function(layer) { map.removeLayer(layer); });
                }
                window.__travelLayers = [];
                window.__activityLayers = {};
                window.__flightLayersByActivity = {};
                window.__photoLayersByActivity = {};
                window.__worldPhotoLayers = [];

                travelData.activities.forEach(function(activity) {
                  const layers = { region: null, route: null, marker: null };
                  const spotPhotos = [];

                  window.__photoLayersByActivity[activity.id] = { spots: [], flightPhotos: [] };

                  if (activity.region.length > 2) {
                    const region = L.polygon(activity.region, {
                      color: defaultColor,
                      weight: 2,
                      fillColor: defaultColor,
                      fillOpacity: 0.03,
                      dashArray: '6 4',
                      opacity: mutedOpacity,
                    });
                    region.addTo(map);
                    window.__travelLayers.push(region);
                    layers.region = region;
                  }

                  if (activity.route.length > 1) {
                    const route = L.polyline(activity.route, {
                      color: defaultColor,
                      weight: 4,
                      opacity: mutedOpacity,
                    });
                    route.addTo(map);
                    window.__travelLayers.push(route);
                    layers.route = route;
                  }

                  const marker = L.marker(activity.pin, {
                    icon: L.divIcon({
                      className: 'travel-marker',
                      html: '<div class="travel-marker-dot ' + activity.type + '"></div>',
                    }),
                  });
                  marker.on('click', function() {
                    window.__openActivity(activity.id, true);
                  });
                  marker.addTo(map);
                  window.__travelLayers.push(marker);
                  layers.marker = marker;

                  window.__activityLayers[activity.id] = layers;
                  drawFlightsForActivity(map, activity);

                  (activity.spots || []).forEach(function(spot) {
                    const marker = createPhotoMarker(map, spot, 'spot');
                    spotPhotos.push(marker);
                  });
                  window.__photoLayersByActivity[activity.id].spots = spotPhotos;
                });

                (travelData.worldPhotos || []).forEach(function(photo) {
                  const marker = createPhotoMarker(map, photo, 'world');
                  window.__worldPhotoLayers.push(marker);
                });
              }

              if (window.__runMap) {
                drawTravelLayers(window.__runMap);
                applyWorldLimits(window.__runMap, true);
                updateFlightCollapse(window.__runMap);
                updateActivityStyles(window.__selectedActivityId || null);
                document.querySelectorAll('.activity-item').forEach(function(el) {
                  el.addEventListener('click', function() {
                    if (!el.id || !el.id.startsWith('activity-item-')) return;
                    window.__openActivity(el.id.slice('activity-item-'.length), true);
                  });
                });
                return;
              }

              const map = L.map('run-map', {
                zoomControl: true,
                attributionControl: true,
                maxBounds: worldBounds,
                maxBoundsViscosity: 1.0,
                worldCopyJump: false,
              });

              L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
                attribution: '&copy; OpenStreetMap &copy; CARTO',
                subdomains: 'abcd',
                maxZoom: 20,
                noWrap: true,
                bounds: worldBounds,
              }).addTo(map);

              applyWorldLimits(map, false);
              drawTravelLayers(map);
              window.__flightUiCollapsed = map.getZoom() <= flightUiCollapseZoom;
              updateActivityStyles(null);

              window.__runMap = map;
              window.__applyWorldLimits = function() { applyWorldLimits(map, true); };

              map.on('zoomend', function() {
                const minZoom = getMinZoom(map, map.getSize());
                if (map.getZoom() < minZoom) {
                  map.setZoom(minZoom);
                }
                updateFlightCollapse(map);
              });

              map.on('moveend', function() {
                updateFlightCollapse(map);
              });

              map.on('resize', window.__applyWorldLimits);
              window.addEventListener('resize', window.__applyWorldLimits);
              setTimeout(window.__applyWorldLimits, 100);
              setTimeout(window.__applyWorldLimits, 500);

              document.querySelectorAll('.activity-item').forEach(function(el) {
                el.addEventListener('click', function() {
                  if (!el.id || !el.id.startsWith('activity-item-')) return;
                  window.__openActivity(el.id.slice('activity-item-'.length), true);
                });
              });
            })();
            """
        ),
    )
}
