import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Terminal from '../Terminal';
import { props, logs } from '../Terminal.fixtures';

describe('Terminal', () => {
  describe('rendering', () => {
    it('should render without props', () => {
      const { container } = render(<Terminal />);
      expect(container.querySelector('.rh-cloud-inventory-terminal')).toBeInTheDocument();
    });

    it('should render with props', () => {
      const { container } = render(<Terminal {...props} />);
      expect(container.querySelector('.rh-cloud-inventory-terminal')).toBeInTheDocument();
    });
  });

  it('handles terminal scroll on componentDidUpdate', () => {
    const { rerender } = render(<Terminal {...props} />);
    const scrollBottomSpy = jest.spyOn(Terminal.prototype, 'scrollBottom');
    rerender(<Terminal {...props} logs={[...logs, 'new-log']} />);
    expect(scrollBottomSpy).toHaveBeenCalled();
    scrollBottomSpy.mockRestore();
  });

  it('error should be displayed in terminal', () => {
    const modifiedProps = { ...props, error: 'some-error' };
    const { container } = render(<Terminal {...modifiedProps} />);
    expect(container.querySelector('p.terminal_error')).toBeInTheDocument();
  });

  it('logs as a string instead of an array should be displayed', () => {
    const text = 'some-string-log';
    const modifiedProps = { ...props, logs: text };
    const { container } = render(<Terminal {...modifiedProps} />);
    expect(container.querySelector('.rh-cloud-inventory-terminal p')).toHaveTextContent(text);
  });
});
