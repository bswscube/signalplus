import { get } from 'lodash';
import { handleActions } from 'redux-actions';
import { createRequestAction } from '../../utils.js';
import Endpoints from '../../../util/endpoints.js';
import { normalizeListenSignalsResponse } from '../../../util/normalize.js';

/*
* Action Type Constants
*/
export const LISTEN_SIGNALS_REQUEST = 'signalplus/listenSignal/REQUEST';
export const LISTEN_SIGNALS_REQUEST_SUCCESS = 'signalplus/listenSignal/REQUEST_SUCCESS';
export const LISTEN_SIGNALS_REQUEST_FAIL = 'signalplus/listenSignal/REQUEST_FAIL';


/*
* Initial State
*/
export const initialState = {
  data: [],
  loaded: false,
  loading: false,
};

/*
* Reducer
*/
export const reducer = handleActions({
  [LISTEN_SIGNALS_REQUEST]: (state, action) => ({
    ...state,
    loading: true,
    loaded: false,
  }),

  [LISTEN_SIGNALS_REQUEST_SUCCESS]: (state, action) => ({
    ...state,
    data: get(normalizeListenSignalsResponse(action.payload), 'entities.listenSignals', []),
    loading: false,
    loaded: true,
  }),

  [LISTEN_SIGNALS_REQUEST_FAIL]: (state, action) => ({
    ...state,
    error: action.payload,
    loading: false,
    loaded: false,
  }),
}, initialState);

export const fetchListenSignalsData = () => {
  return createRequestAction({
    endpoint: Endpoints.LISTEN_SIGNALS_INDEX,
    types: [
      LISTEN_SIGNALS_REQUEST,
      { type: LISTEN_SIGNALS_REQUEST_SUCCESS },
      LISTEN_SIGNALS_REQUEST_FAIL,
    ],
  });
};
