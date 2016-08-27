import MainView from './MainView';
import PageRunView from './PageRunView';

// Collection of specific view modules
const views = {
  PageRunView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
