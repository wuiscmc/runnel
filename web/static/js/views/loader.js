import MainView from './MainView';
import PageRunView from './PageRunView';
import PageSee_stuffView from './PageSee_stuffView';

// Collection of specific view modules
const views = {
  PageRunView,
  PageSee_stuffView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
