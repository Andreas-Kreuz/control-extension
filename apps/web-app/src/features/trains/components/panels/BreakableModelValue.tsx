function BreakableModelValue(props: { value: string }) {
  const parts = props.value.split('\\');

  return (
    <>
      {parts.map((part, index) => (
        <span key={`${part}-${index}`}>
          {index > 0 && (
            <>
              {'\\'}
              <wbr />
            </>
          )}
          {part}
        </span>
      ))}
    </>
  );
}

export default BreakableModelValue;
