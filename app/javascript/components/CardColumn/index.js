import React, {useState, useContext, useEffect} from 'react';
import {useSubscription} from '@apollo/react-hooks';
import Card from './Card';
import CardPopup from './Card/card-popup/card-popup';
import {
  cardAddedSubscription,
  cardDestroyedSubscription,
  cardUpdatedSubscription
} from './operations.gql';
import UserContext from '../../utils/user_context';
import BoardSlugContext from '../../utils/board_slug_context';
import '../table.css';
import NewCardBody from '../new-card-body/new-card-body';

const CardColumn = ({kind, initCards, currentUser}) => {
  const user = useContext(UserContext);
  const boardSlug = useContext(BoardSlugContext);
  const [cards, setCards] = useState(initCards);
  const [skip, setSkip] = useState(true); // Workaround for https://github.com/apollographql/react-apollo/issues/3802
  const [popupShownId, setPopupShownId] = useState(null);

  const handleCommentButtonClick = (id) => () => setPopupShownId(id);
  const handlePopupClose = () => setPopupShownId(null);

  useSubscription(cardAddedSubscription, {
    skip,
    onSubscriptionData: (options) => {
      const {data} = options.subscriptionData;
      const {cardAdded} = data;
      if (cardAdded) {
        if (cardAdded.kind === kind && cardAdded.author.email !== user) {
          setCards((oldCards) => [cardAdded, ...oldCards]);
        }
      }
    },
    variables: {boardSlug}
  });

  useSubscription(cardDestroyedSubscription, {
    skip,
    onSubscriptionData: (options) => {
      const {data} = options.subscriptionData;
      const {cardDestroyed} = data;
      if (cardDestroyed && cardDestroyed.kind === kind) {
        setCards((oldCards) =>
          oldCards.filter((element) => element.id !== cardDestroyed.id)
        );
      }
    },
    variables: {boardSlug}
  });

  useSubscription(cardUpdatedSubscription, {
    skip,
    onSubscriptionData: (options) => {
      const {data} = options.subscriptionData;
      const {cardUpdated} = data;
      if (cardUpdated && cardUpdated.kind === kind) {
        setCards((oldCards) => {
          const cardIdIndex = oldCards.findIndex(
            (element) => element.id === cardUpdated.id
          );
          if (cardIdIndex >= 0) {
            return [
              ...oldCards.slice(0, cardIdIndex),
              cardUpdated,
              ...oldCards.slice(cardIdIndex + 1)
            ];
          }

          return oldCards;
        });
      }
    },
    variables: {boardSlug}
  });

  useEffect(() => {
    setSkip(false);
  }, []);

  const card = cards.find((it) => it.id === popupShownId);

  return (
    <>
      <NewCardBody
        kind={kind}
        currentUser={currentUser}
        onCardAdded={(cardAdded) => {
          setCards((oldCards) => [cardAdded, ...oldCards]);
        }}
        onGetNewCardID={(cardMockid, cardId) => {
          setCards((oldCards) => {
            oldCards[
              oldCards.findIndex((it) => it.id === cardMockid)
            ].id = cardId;
            return oldCards;
          });
        }}
      />

      {cards.map((card) => {
        return (
          <Card
            key={card.id}
            {...card}
            type={kind}
            onCommentButtonClick={handleCommentButtonClick(card.id)}
          />
        );
      })}

      {popupShownId && (
        <CardPopup
          id={card.id}
          nickname={card.author.nickname}
          lastName={card.author.last_name}
          firstName={card.author.first_name}
          avatar={card.author.avatar.thumb.url}
          body={card.body}
          likes={card.likes}
          type={kind}
          commentsNumber={card.comments.length}
          editable={user === card.author.email}
          deletable={user === card.author.email}
          comments={card.comments}
          onCommentButtonClick={() => {}}
          onClickClosed={handlePopupClose}
        />
      )}
    </>
  );
};

export default CardColumn;
