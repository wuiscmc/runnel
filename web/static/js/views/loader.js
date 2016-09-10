import MainView from './MainView';
import PageIndexView from './PageIndexView';
import PageShowView from './PageShowView';

// Collection of specific view modules
const views = {
  PageShowView,
  PageIndexView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
