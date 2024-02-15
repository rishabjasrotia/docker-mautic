<?php

namespace LightSaml\Action\Profile\Inbound\Response;

use LightSaml\Action\Profile\AbstractProfileAction;
use LightSaml\Context\Profile\Helper\MessageContextHelper;
use LightSaml\Context\Profile\ProfileContext;
use LightSaml\Resolver\Session\SessionProcessorInterface;
use Psr\Log\LoggerInterface;

class SpSsoStateAction extends AbstractProfileAction
{
    /** @var SessionProcessorInterface */
    private $sessionProcessor;

    public function __construct(LoggerInterface $logger, SessionProcessorInterface $sessionProcessor)
    {
        parent::__construct($logger);

        $this->sessionProcessor = $sessionProcessor;
    }

    protected function doExecute(ProfileContext $context)
    {
        $response = MessageContextHelper::asResponse($context->getInboundContext());

        $this->sessionProcessor->processAssertions(
            $response->getAllAssertions(),
            $context->getOwnEntityDescriptor()->getEntityID(),
            $context->getPartyEntityDescriptor()->getEntityID()
        );
    }
}
