import React, {useState, useContext, useEffect} from 'react';
import {useSubscription} from '@apollo/react-hooks';
import {Card} from '../card';
import {
  cardAddedSubscription,
  cardDestroyedSubscription,
  cardUpdatedSubscription
} from './operations.gql';
import UserContext from '../../utils/user-context';
import BoardSlugContext from '../../utils/board-slug-context';
import {NewCardBody} from '../new-card-body';

const CardColumn = ({kind, initCards, smile}) => {
  const currentUser = useContext(UserContext);
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
        if (
          cardAdded.kind === kind &&
          cardAdded.author.id !== currentUser.id.toString()
        ) {
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

  return (
    <>
      <NewCardBody
        kind={kind}
        smile={smile}
        handleCardAdd={(cardAdded) => {
          setCards((oldCards) => [cardAdded, ...oldCards]);
        }}
        handleGetNewCardID={(cardMockid, cardId) => {
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
            isCommentsShown={popupShownId === card.id}
            onClickClosed={handlePopupClose}
            onCommentButtonClick={handleCommentButtonClick(card.id)}
          />
        );
      })}
    </>
  );
};

export default CardColumn;
