import {useMutation} from '@apollo/react-hooks';
import React, {useContext, useMemo, useState} from 'react';
import BoardSlugContext from '../../utils/board-slug-context';
import {handleKeyPress} from '../../utils/helpers';
import UserContext from '../../utils/user-context';
import {ActionItemEdit} from '../action-item-edit';
import CardUser from '../card-user/card-user';
import {addActionItemMutation} from './operations.gql';
import style from './style.module.less';

const NewActionItem = ({users}) => {
  const currentUser = useContext(UserContext);
  const [isOpened, setOpened] = useState(false);
  const [newActionItemBody, setNewActionItemBody] = useState('');
  const [newActionItemAssigneeId, setNewActionItemAssigneeId] = useState('');
  const [addActionItem] = useMutation(addActionItemMutation);
  const boardSlug = useContext(BoardSlugContext);

  const cancelHandler = (evt) => {
    evt.preventDefault();
    setOpened(!isOpened);
    setNewActionItemBody('');
  };

  const submitHandler = async (evt) => {
    evt.preventDefault();

    const {data} = await addActionItem({
      variables: {
        boardSlug,
        assigneeId: newActionItemAssigneeId,
        body: newActionItemBody
      }
    });
    if (data.addActionItem.actionItem) {
      setNewActionItemBody('');
    } else {
      console.log(data.addActionItem.errors.fullMessages.join(' '));
    }
  };

  const handleEscapeClick = () => {
    setOpened(!isOpened);
    setNewActionItemBody('');
  };

  const currentAssignee = useMemo(
    () => users.find((user) => user.id.toString() === newActionItemAssigneeId),
    [newActionItemAssigneeId]
  );
  return (
    <div className={style.newActionItem}>
      <CardUser
        id={currentUser.id}
        firstName={currentUser.firstName}
        lastName={currentUser.lastName}
        nickname={currentUser.nickname}
        avatar={currentUser.avatar}
      />
      <ActionItemEdit
        users={users}
        submitHandler={submitHandler}
        cancelHandler={cancelHandler}
        body={newActionItemBody}
        setBody={setNewActionItemBody}
        handleKeyPress={(evt) =>
          handleKeyPress(evt, submitHandler, handleEscapeClick)
        }
        isOpened={isOpened}
        setOpened={setOpened}
        newActionItemAssigneeId={newActionItemAssigneeId}
        setNewActionItemAssigneeId={setNewActionItemAssigneeId}
        currentAssignee={currentAssignee}
        doNotAssign={() => {
          setNewActionItemAssigneeId(null);
          setOpened(false);
        }}
      />
    </div>
  );
};

export default NewActionItem;
