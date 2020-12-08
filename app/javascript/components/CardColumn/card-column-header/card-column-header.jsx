import React, {useState, useContext, useEffect, useRef} from 'react';
import {useMutation} from '@apollo/react-hooks';
import Textarea from 'react-textarea-autosize';
import {addCardMutation} from '../operations.gql';
import BoardSlugContext from '../../../utils/board_slug_context';

const CardColumnHeader = ({kind, onCardAdded, onGetIdNewCard, currentUser}) => {
  const textInput = useRef();
  const [isOpened, setOpened] = useState(false);
  const [newCard, setNewCard] = useState('');
  const [addCard] = useMutation(addCardMutation);

  const boardSlug = useContext(BoardSlugContext);

  const toggleOpen = () => setOpened(!isOpened);

  useEffect(() => {
    if (isOpened) {
      textInput.current.focus();
    }
  }, [isOpened]);

  const cancelHandler = e => {
    e.preventDefault();
    setOpened(isOpened => !isOpened);
    setNewCard('');
  };

  const buildNewCard = () => {
    const card = {};
    card.likes = 0;
    card.comments = [];
    card.kind = kind;
    card.author = currentUser;
    card.body = newCard;
    card.id = `tmp-${Math.random()}`;
    return card;
  };

  const submitHandler = e => {
    const card = buildNewCard();
    e.preventDefault();

    onCardAdded(card);

    addCard({
      variables: {
        boardSlug,
        kind,
        body: newCard
      }
    }).then(({data}) => {
      if (data.addCard.card) {
        onGetIdNewCard(card.id, data.addCard.card.id);
        setNewCard('');
      } else {
        console.log(data.addCard.errors.fullMessages.join(' '));
      }
    });
  };

  const handleKeyPress = e => {
    if (navigator.platform.includes('Mac')) {
      if (e.key === 'Enter' && e.metaKey) {
        submitHandler(e);
      }
    } else if (e.key === 'Enter' && e.ctrlKey) {
      submitHandler(e);
    }

    if (e.key === 'Escape') {
      setOpened(isOpened => !isOpened);
      setNewCard('');
    }
  };

  return (
    <>
      <div className="board-column-title">
        <h2 className="float_left">{kind.toUpperCase()}</h2>
        <div className="float_right card-new" onClick={toggleOpen}>
          +
        </div>
      </div>
      {isOpened && (
        <div>
          <form onSubmit={submitHandler}>
            <Textarea
              ref={textInput}
              className="input"
              autoComplete="off"
              id={`card_${kind}_body`}
              value={newCard}
              onChange={e => setNewCard(e.target.value)}
              onKeyDown={handleKeyPress}
            />
            <div className="card-buttons">
              <button
                className="tag is-success button card-add"
                type="submit"
                onSubmit={submitHandler}
              >
                Add
              </button>
              <button
                className="tag button card-cancel"
                type="submit"
                onClick={cancelHandler}
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}
    </>
  );
};

export default CardColumnHeader;
