import React, {useState, useEffect} from 'react';
import {useMutation} from '@apollo/react-hooks';
import {likeCardMutation} from './operations.gql';
const EMOJIES = {
  mad: '😡',
  sad: '😔',
  glad: '🤗',
  universal: '👍'
};

const Likes = ({type, likes, id}) => {
  const [likeCard] = useMutation(likeCardMutation);
  const [style, setStyle] = useState('has-text-info');
  const [timer, setTimer] = useState(null);

  useEffect(() => {
    return function () {
      clearInterval(timer);
    };
  }, [timer]);

  const addLike = async () => {
    const {data} = await likeCard({
      variables: {
        id
      }
    });

    if (!data.likeCard.card) {
      console.log(data.likeCard.errors.fullMessages.join(' '));
    }
  };

  const handleMouseDown = () => {
    setStyle({style: 'has-text-success'});
    addLike();
    const timer = setInterval(() => addLike(), 300);
    setTimer(timer);
  };

  const handleMouseUp = (currentTimer) => {
    setStyle('has-text-info');
    clearInterval(currentTimer);
  };

  const handleMouseLeave = (currentTimer) => {
    setStyle('has-text-info');
    clearInterval(currentTimer);
  };

  return (
    <div
      style={{cursor: 'pointer'}}
      onMouseDown={handleMouseDown}
      onMouseUp={() => handleMouseUp(timer)}
      onMouseLeave={() => handleMouseLeave(timer)}
    >
      <a className={style}>{EMOJIES[type] || EMOJIES.universal}</a>
      <span> {likes} </span>
    </div>
  );
};

export default Likes;
