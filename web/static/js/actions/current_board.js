import Constants  from '../constants';

const Actions = {
  showForm: (show) => {
    return dispatch => {
      dispatch({
        type: Constants.CURRENT_BOARD_SHOW_FORM,
        show: show,
      });
    };
  },

  connectToChannel: (socket, boardId) => {
    return dispatch => {
      let channel = socket.channel(`boards:${boardId}`);

      channel.join().receive('ok', (response) => {
        dispatch({
          type: Constants.BOARDS_SET_CURRENT_BOARD,
          board: response.board,
        });
      });

      channel.on('user:joined', (msg) => {
        dispatch({
          type: Constants.CURRENT_BOARD_CONNECTED_USERS,
          users: msg.users,
        });
      });

      channel.on('user:left', (msg) => {
        dispatch({
          type: Constants.CURRENT_BOARD_CONNECTED_USERS,
          users: msg.users,
        });
      });

      channel.on('list:created', (msg) => {
        dispatch({
          type: Constants.CURRENT_BOARD_LIST_CREATED,
          list: msg.list,
        });
      });

      dispatch({
        type: Constants.CURRENT_BOARD_CONNECTED_TO_CHANNEL,
        channel: channel,
      });
    };
  },

  leaveChannel: (channel) => {
    return dispatch => {
      channel.leave();

      dispatch({
        type: Constants.CURRENT_BOARD_RESET,
      });
    };
  },
};

export default Actions;