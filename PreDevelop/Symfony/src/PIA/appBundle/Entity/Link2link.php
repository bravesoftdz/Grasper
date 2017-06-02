<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Link2link
 */
class Link2link
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var \PIA\appBundle\Entity\Links
     */
    private $masterLink;

    /**
     * @var \PIA\appBundle\Entity\Links
     */
    private $slaveLink;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set masterLink
     *
     * @param \PIA\appBundle\Entity\Links $masterLink
     * @return Link2link
     */
    public function setMasterLink(\PIA\appBundle\Entity\Links $masterLink = null)
    {
        $this->masterLink = $masterLink;

        return $this;
    }

    /**
     * Get masterLink
     *
     * @return \PIA\appBundle\Entity\Links 
     */
    public function getMasterLink()
    {
        return $this->masterLink;
    }

    /**
     * Set slaveLink
     *
     * @param \PIA\appBundle\Entity\Links $slaveLink
     * @return Link2link
     */
    public function setSlaveLink(\PIA\appBundle\Entity\Links $slaveLink = null)
    {
        $this->slaveLink = $slaveLink;

        return $this;
    }

    /**
     * Get slaveLink
     *
     * @return \PIA\appBundle\Entity\Links 
     */
    public function getSlaveLink()
    {
        return $this->slaveLink;
    }
}
